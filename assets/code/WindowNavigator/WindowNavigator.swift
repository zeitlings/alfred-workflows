//
//  WindowNavigator.swift
//  Window Navigator Alfred Workflow (v2.0.0)
//
//  Navigate to any window of the active app over all desktop spaces
//  or Switch to a window open in the current desktop space.
//  <https://github.com/zeitlings/alfred-workflows>
//
//  Created by Patrick Sy on 21/05/2024.
//

import ApplicationServices

// MARK: - WindowNavigator
struct WindowNavigator {
	private static let stdOut: FileHandle = .standardOutput
	static let cacheDuration: TimeInterval = Environment.cacheLifetime
	static let frontMostApplicationName: String? = NSWorkspace.shared.frontmostApplication?.localizedName
	static let directive: Directive = .init(rawValue: CommandLine.arguments[1])!
	static var windowNameCandidates: Set<String>?
	
	static func run() {
		tryCachedWindows()
		windowNameCandidates = getCandidates()
		let items: [Item]
		switch directive {
		case .navigator: items = relativeWindows.map({ $0.alfredItem })
		case .switcher:  items = onScreenWindows.map({ $0.alfredItem })
		case .global:    items = completeWindows.map({ $0.alfredItem })
		}
		yield(items: items, save: true)
	}
	
	static func getCandidates() -> Set<String> {
		guard directive != .switcher else {
			return []
		}
		var windowCandidates: Set<String> = []
		var observedFrauds: Set<String> = []
		let runningApplications: [NSRunningApplication] = NSWorkspace.shared.runningApplications.deduplicated()
		
		for application in runningApplications {
			guard let applicationName: String = application.localizedName else {
				Environment.log("[WARNING] Application with PID <\(application.processIdentifier)> has no localized name")
				continue
			}
			guard !knownFrauds.contains(applicationName),
				  !knownFraudsSharedPrefixes.anySatisfy({ applicationName.hasPrefix($0) }),
				  !knownFraudsSharedSuffixes.anySatisfy({ applicationName.hasSuffix($0) })
			else {
				continue
			}
			let axApp: AXUIElement = AXUIElementCreateApplication(application.processIdentifier)
			guard let targetMenuBar: AXUIElement = axApp.menunBar else {
				Environment.log("[INFO] Could not retrieve menu bar of application with name <\(application.localizedName ?? "Unknown")> PID <\(application.processIdentifier)>")
				if let appName: String = application.localizedName {
					observedFrauds.insert(appName)
				}
				continue
			}
			
			if let menuItems: [AXUIElement] = targetMenuBar.children {
				// Reverse the array to crawl the list starting with Help > Window ... then each sub bar from the bottom
				for menuItem: AXUIElement in menuItems.reversed() {
					guard localizedWindowMenubarNames.contains(menuItem.name ?? "") else {
						continue
					}
					if let extraElement: AXUIElement = menuItem.children?.first,
					   let menuBarItems: [AXUIElement] = extraElement.children
					{
						// TODO: Drop suffix tested: no
						let candidates: [String] = menuBarItems.compactMap({ $0.name?.droppingSuffix() }).filter({ !$0.isEmpty })
						windowCandidates.formUnion(candidates)
					}
				}
			}
		}
		
		if !observedFrauds.isEmpty {
			Environment.log("Remembering \(observedFrauds.count) new \(observedFrauds.count == 1 ? "process" : "processes") to ignore.")
			Environment.log(" ~ \(Environment.runtimeFraudsFile.path)")
			remember(frauds: observedFrauds)
		}
		
		return windowCandidates
	}
	
	/// A list of `WindowWrapper` objects representing all on-screen windows.
	///
	/// This property retrieves information about all on-screen windows, excluding desktop elements,
	/// and converts them into an array of `WindowWrapper` objects. If the window list cannot be retrieved,
	/// the application will terminate with a precondition failure.
	///
	/// - Returns: An array of `WindowWrapper` objects representing the on-screen windows.
	private static let onScreenWindows: [WindowWrapper] = {
		let onScreenWindowList: CFArray? = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
		guard let onScreenWindows = onScreenWindowList as? [[String: Any]] else {
			preconditionFailure("Unable to retrieve on-screen window list")
		}
		let windows: [WindowWrapper] = onScreenWindows
			.compactMap({ WindowWrapper($0) })

		switch directive {
		case .navigator: return windows
		case .switcher:  return (Environment.includeFrontmostWindow ? windows : .init(windows.dropFirst())).sorted(by: { $0.owningApplicationPID < $1.owningApplicationPID })
		case .global: return windows.first != nil ? [windows.first!] : []
		}
	}()
	
	/// A list of `WindowWrapper` objects representing alll windows relative to the frontmost active window.
	///
	/// This property retrieves a list of windows related to the frontmost active window, filtering
	/// them based on their process identifier (PID) to include only those belonging to the same
	/// application. It optionally includes the frontmost window itself based on the environment setting.
	///
	/// - Returns: An array of `WindowWrapper` objects representing the windows relative to the frontmost active window.
	private static let relativeWindows: [WindowWrapper] = {
		guard let frontMost: WindowWrapper = onScreenWindows.first(where: { $0.windowIsOnScreen }) else {
			yield(items: [.noWindows], save: false)
		}
		
		let frontMostApplicationWindowID: CGWindowID = CGWindowID(frontMost.windowNumber)
		let frontMostApplicationPID: Int32 = frontMost.owningApplicationPID
		
		// Matching the PID of the owning application works for some reason and results in the active window being included.
		let relativeWindowList: CFArray? = Environment.includeFrontmostWindow
			? CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], CGWindowID(frontMostApplicationPID))
			: CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], frontMostApplicationWindowID)
		
		guard let relativeWindows = relativeWindowList as? [[String: Any]] else {
			preconditionFailure("Unable to retrieve global window list of frontmost on-screen application")
		}
		
		let windows: [WindowWrapper] = relativeWindows.lazy
			.compactMap({ .init($0) })
			.filter({ $0.owningApplicationPID == frontMostApplicationPID })
			.deduplicated()
			.filter({ $0.isValidWindow })
		
		return windows.sorted(by: { $0.owningApplicationPID < $1.owningApplicationPID })
	}()
	
	private static let completeWindows: [WindowWrapper] = {
		let globalWindowList: CFArray? = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID)
		guard let allWindows = globalWindowList as? [[String: Any]] else {
			preconditionFailure("Unable to retrieve global window list")
		}
		
		// TODO: Group the apps together?
		var windows: [WindowWrapper] = allWindows
			.compactMap({ .init($0) })
			.deduplicated()
			.filter({ $0.isValidWindow })
		if
			!Environment.includeFrontmostWindow,
			let first: WindowWrapper = onScreenWindows.first,
			let index: Int = windows.firstIndex(where: { $0.windowNumber == first.windowNumber })
		{
			windows.remove(at: index)
		}
		return windows.sorted(by: { $0.owningApplicationPID < $1.owningApplicationPID })
	}()
	
	/// Outputs the given items as an Alfred script filter response and terminates the program.
	///
	/// - Parameters:
	///   - items: An array of `Item` objects to be included in the response.
	private static func yield(items: [Item], save saveCache: Bool) -> Never {
		if items.isEmpty {
			try? stdOut.write(contentsOf: Response(items: [.noWindows]).encoded(save: false))
		} else {
			try? stdOut.write(contentsOf: Response(items: items).encoded(save: saveCache))
		}
		Darwin.exit(EXIT_SUCCESS)
	}
	
	/// Verifies screen capture access for the application and requests access if necessary.
	///
	/// - Returns: `nil` if screen capture access is already granted. If access is not granted,
	///   the function requests access and terminates the program, thus it does not return in this case.
	@discardableResult
	static func permissions() -> Never? {
		guard CGPreflightScreenCaptureAccess() else {
			CGRequestScreenCaptureAccess()
			Darwin.exit(EXIT_SUCCESS)
		}
		return nil
	}

}

extension WindowNavigator {
	
	@discardableResult
	static func tryCachedWindows(fm: FileManager = .default) -> Never? {
		guard directive != .switcher,
			  !Environment.cacheFeedbackGiven,
			  fm.fileExists(atPath: Environment.cacheFile.path)
		else {
			return nil
		}
		
		if let cached: Data = fm.contents(atPath: Environment.cacheFile.path),
		   let wrapper: [CacheWrapper] = try? JSONDecoder().decode([CacheWrapper].self, from: cached),
		   let cached: CacheWrapper = wrapper.first(where: { $0.directive == directive }),
		   !cached.isStale
		{
			let old: Response = cached.response
			// FIXME: potentially a source of problems
			let variables = old.variables?.merging(["cache_feedback_given": "true"], uniquingKeysWith: { _, new in new })
			var response: Response = .init(items: old.items, rerun: 0.1, variables: variables)
			
			if WindowNavigator.directive == .navigator,
			   let frontmost = WindowNavigator.frontMostApplicationName,
			   cached.frontmostApplication != frontmost,
			   let global = wrapper.first(where: { $0.directive == .global })
			{
				let items: [Item] = global.response.items.filter({ $0.subtitle == frontmost })
				response.items = items
			}
			
			if response.items.isEmpty {
				yield(items: [.noWindows], save: directive == .navigator)
			} else {
				try? stdOut.write(contentsOf: response.encoded(save: false))
			}
			Darwin.exit(EXIT_SUCCESS)
		}
		
		return nil
	}
	
}

// MARK: - Item
struct Item: Codable, Hashable, Equatable {
	let title: String
	let subtitle: String
	let arg: [String]?
	let variables: [String: String]?
	let uid: String
	let icon: [String: String]
	let autocomplete: String?
	let match: String?
	let text: [String:String]?
	let valid: Bool
	
	
	static let noWindows: Item = {
		let subtitle: String = {
			switch WindowNavigator.directive {
			case .navigator:
				guard let appName: String = WindowNavigator.frontMostApplicationName else {
					return "Ensure at least one window is visible in the current desktop space."
				}
				return "Ensure at least one other \(appName) window is visible in any desktop space."
				
			case .switcher:
				return Environment.includeFrontmostWindow
					? "Ensure at least one window is visible in the current desktop space."
					: "Ensure at least one other window is visible in the current desktop space."
				
			case .global:
				return "Ensure at least one window is visible in any desktop space."
				
			}
		}()
		
		return .init(
			title: "No windows",
			subtitle: subtitle,
			arg: nil,
			variables: nil,
			uid: "",
			icon: ["path":"icons/info.png"],
			autocomplete: nil,
			match: nil,
			text: nil,
			valid: false
		)
	}()
}

// MARK: - Response
struct Response: Codable {
	var items: [Item]
	var variables: [String:String]?
	var skipknowledge: Bool = true
	var rerun: Double?
	
	init(
		items: [Item],
		rerun: Double? = nil,
		variables: [String:String]? = ["trigger":"raise_window"]
	) {
		self.items = items
		self.rerun = rerun
		self.variables = variables
	}
	
	func encoded(fm: FileManager = .default, save saveCache: Bool) -> Data {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		if saveCache {
			let wrapper: CacheWrapper = .init(
				directive: WindowNavigator.directive,
				timestamp: .now,
				frontmostApplication: WindowNavigator.frontMostApplicationName ?? "",
				response: self
			)
			
			if let cached: Data = fm.contents(atPath: Environment.cacheFile.path),
			   var cached: [CacheWrapper] = try? JSONDecoder().decode([CacheWrapper].self, from: cached)
			{
				if let replacementIndex = cached.firstIndex(where: { $0.directive == wrapper.directive }) {
					cached[replacementIndex] = wrapper
				} else {
					cached.append(wrapper)
				}
				let extendedCacheEncoded: Data = try! encoder.encode(cached)
				try? extendedCacheEncoded.write(to: Environment.cacheFile)
			} else {
				let cacheEncoded: Data = try! encoder.encode([wrapper])
				try? cacheEncoded.write(to: Environment.cacheFile)
			}
			
		}
		
		let encoded = try! encoder.encode(self)
		return encoded
	}
}

// MARK: - CacheWrapper
struct CacheWrapper: Codable {
	let directive: Directive
	let timestamp: Date
	let frontmostApplication: String
	let response: Response
	
	var isStale: Bool {
		Date().timeIntervalSince(timestamp) > WindowNavigator.cacheDuration
	}
}

// MARK: - WindowWrapper
struct WindowWrapper: CustomDebugStringConvertible, Hashable {
	let owningApplicationName: String
	let owningApplicationPID: Int32
	let applicationPath: String
	let windowTitle: String
	let windowNumber: Int32
	let windowLayer: Int
	let windowAlpha: CGFloat
	let windowBounds: NSRect
	let windowIsOnScreen: Bool
	let windowBackingType: WindowBackingType
	let windowSharingState: WindowSharingState
	let windowMemoryUsage: Double
	
	init?(_ info: [String : Any]) {
		guard
			let owningApplicationName = info[kCGWindowOwnerName as String] as? String,
			let owningApplicationPID = info[kCGWindowOwnerPID as String] as? Int32,
			let applicationPath = NSRunningApplication(processIdentifier: owningApplicationPID)?.bundleURL?.path,
			let windowNumber = info[kCGWindowNumber as String] as? Int32,
			let windowLayer = info[kCGWindowLayer as String] as? Int,
			let windowTitle = info[kCGWindowName as String] as? String,
			let windowAlpha = info[kCGWindowAlpha as String] as? CGFloat,
			let windowMemoryUsage = info[kCGWindowMemoryUsage as String] as? Double,
			let windowSharingState = info[kCGWindowSharingState as String] as? Int32,
			let windowBackingType = info[kCGWindowStoreType as String] as? UInt32,
			let windowBounds = info[kCGWindowBounds as String] as? [String: Int32],
			let windowWidth = windowBounds["Width"],
			let windowHeight = windowBounds["Height"],
			let windowX = windowBounds["X"],
			let windowY = windowBounds["Y"]
		else {
			return nil
		}
		
		// TODO: Preserve the Emoji / Character Viewer
		// Exceptions: Character Viewer (Layer 20). Not caught.
		
		guard windowLayer == 0 else { return nil } // isWindow
		guard windowAlpha > 0 else  { return nil }
		guard !windowTitle.isEmpty || windowHeight > 70 else { return nil }
		
		if !Environment.preserveWindowsWithoutName {
			guard !windowTitle.isEmpty else { return nil }
		}
		
		if let blacklist: [String] = Environment.ignoredWindowNames {
			guard blacklist.firstIndex(of: windowTitle) == nil else {
				return nil
			}
		}
		
		let bounds = NSRect(
			origin: NSPoint(x: CGFloat(windowX), y: CGFloat(windowY)),
			size: NSSize(width: CGFloat(windowWidth), height: CGFloat(windowHeight))
		)
		
		self.owningApplicationName = String(owningApplicationName.unicodeScalars.prefix(while: { $0 != "." }))
		self.owningApplicationPID = owningApplicationPID
		self.applicationPath = applicationPath
		self.windowTitle = windowTitle.isEmpty ? owningApplicationName : windowTitle
		self.windowNumber = windowNumber
		self.windowAlpha = windowAlpha
		self.windowIsOnScreen = info[kCGWindowIsOnscreen as String] as? Bool ?? false
		self.windowLayer = windowLayer
		self.windowBounds = bounds
		self.windowBackingType = .init(rawValue: windowBackingType) ?? .backingStoreUnknown
		self.windowSharingState = .init(rawValue: windowSharingState) ?? .unknown
		self.windowMemoryUsage = windowMemoryUsage
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(windowBounds.size.width)
		hasher.combine(windowBounds.size.height)
		hasher.combine(windowBounds.origin.x)
		hasher.combine(windowBounds.origin.y)
		hasher.combine(self.windowTitle)
	}
	
	static func == (lhs: WindowWrapper, rhs: WindowWrapper) -> Bool {
		lhs.windowBounds == rhs.windowBounds
		&& lhs.windowTitle == rhs.windowTitle
	}
	
	// kCGWindowStoreType
	enum WindowBackingType: UInt32, CustomStringConvertible {
		case backingStoreRetained = 0
		case backingStoreNonretained = 1
		case backingStoreBuffered = 2
		case backingStoreUnknown = 404
		
		var description: String {
			switch self {
			case .backingStoreRetained: return "Backing Store Retained"
			case .backingStoreNonretained: return "Backing Store Nonretained"
			case .backingStoreBuffered: return "Backing Store Buffered"
			case .backingStoreUnknown: return "Backing Store Unexpected Unknown"
			}
		}
	}
	
	// kCGWindowSharingState
	enum WindowSharingState: Int32, CustomStringConvertible {
		case none = 1
		case readOnly = 2
		case readWrite = 3
		case unknown = 404
		
		var description: String {
			switch self {
			case .none: return "none"
			case .readOnly: return "read only"
			case .readWrite: return "read-write"
			case .unknown: return "sharing state unexpected unknown"
			}
		}
	}
	
	// RIP CGWindowListCreateImage
	/// If we succeed in creating a composited image representation of the window, then it is an actual window visible somewhere on some workspace.
	var isValidWindow: Bool {
		var title: String = windowTitle
		title.removeAll(where: { !$0.isLetter })
		let fuzzyComponents: [String] = windowTitle
			.components(separatedBy: .whitespaces)
			.filter({
				$0.count > 1 && $0 != "Edited"
			})
		
		if let candidates = WindowNavigator.windowNameCandidates,
		   (candidates.contains(windowTitle)
			|| candidates.anySatisfy({ c in
			   fuzzyComponents.allSatisfy({ c.hasSubstring($0) })
		   }))
		{
			return true
		}
		return false
	}
	
	var debugDescription: String {
		"""
		Window {
			Application: \(owningApplicationName) (pid: \(owningApplicationPID))
			Window Name: 		\(windowTitle)
			  | Layer: 	 		\(windowLayer)
			  | Number:  		\(windowNumber)
			  | Alpha: 	 		\(windowAlpha)
			  | On Screen: 		\(windowIsOnScreen)
			  | Backing Type: 	\(windowBackingType.description)
			  | Sharing State: 	\(windowSharingState.description)
			  | Memory Usage: 	\(windowMemoryUsage)
			  | Window Bounds: {
					width:  \(windowBounds.size.width)
					height: \(windowBounds.size.height)
					x: 		\(windowBounds.origin.x)
					y: 		\(windowBounds.origin.y)
				}
		}
		"""
	}
	
	var alfredItem: Item {
		let text = Environment.isDebugPanelOpen
			? ["largetype":"\(windowTitle)\n\(owningApplicationName)\n\n\(debugDescription)"]
			: ["largetype":"\(windowTitle)\n\(owningApplicationName)"]
		return Item(
			title: windowTitle,
			subtitle: owningApplicationName,
			arg: nil,
			variables: [
				"app_pid":  "\(owningApplicationPID)",
				"app_name": "\(owningApplicationName)",
				"win_num":  "\(windowNumber)",
				"win_name": "\(windowTitle)"
			],
			uid: windowTitle,
			icon: ["type": "fileicon", "path": applicationPath],
			autocomplete: owningApplicationName,
			match: "\(windowTitle) \(owningApplicationName)",
			text: text,
			valid: true
		)
	}
	
}

// MARK: - Environment
struct Environment {
	static private let env: [String:String] = ProcessInfo.processInfo.environment
	static let shouldRaiseWindow: Bool = env["trigger"] == "raise_window" && env["app_pid"] != nil && env["win_num"] != nil && env["win_name"] != nil
	static let shouldCloseWindow: Bool = env["trigger"] == "close_window" && env["app_pid"] != nil && env["win_num"] != nil && env["win_name"] != nil
	static let applicationPID: Int32 = Int32(env["app_pid"]!)!
	static let windowNumber: Int32 = Int32(env["win_num"]!)!
	static let windowName: String = env["win_name"]!
	static let includeFrontmostWindow: Bool = env["include_top_win"] == "1"
	static let preserveWindowsWithoutName: Bool = env["preserve_unnamed_windows"] == "1"
	static let ignoredWindowNames: [String]? = env["ignored_window_names"]?.split(separator: ",").map(\.trimmed)
	static let isDebugPanelOpen: Bool = env["alfred_debug"] == "1"
	static let cacheLifetime: TimeInterval = TimeInterval(env["cache_lifetime"] ?? "2400")! // 1200 - 20 mins
	static let cacheFolder: URL = URL(file: env["alfred_workflow_cache"]!)
	static let cacheFile: URL = cacheFolder.appendingPathComponent("windows.json")
	static let cacheFeedbackGiven: Bool = env["cache_feedback_given"] == "true"
	static let dataFolder: URL = URL(file: env["alfred_workflow_data"]!)
	static let runtimeFraudsFile: URL = dataFolder.appending(component: "runtime_frauds.txt")
	
	static private let stdErr: FileHandle = .standardError
	static func log(_ message: String) {
		try? stdErr.write(contentsOf: Data("\(message)\n".utf8))
	}
}

// MARK: - Directive
enum Directive: String, Codable {
	case navigator
	case switcher
	case global
}


// MARK: - Accessibility
extension WindowNavigator {

	struct AX {
		
		// MARK: Raise Window
		static func raise(
			applicationPID: Int32 = Environment.applicationPID,
			windowNumber: Int32 = Environment.windowNumber,
			windowName: String = Environment.windowName
		) -> Never {
			let axApp: AXUIElement = AXUIElementCreateApplication(pid_t(applicationPID))
			if let axWindow: AXUIElement = axApp.windowWithinCurrentDesktopSpace(windowNumber: windowNumber) {
				NSRunningApplication(processIdentifier: pid_t(applicationPID))?.activate()
				AXUIElementPerformAction(axWindow, kAXRaiseAction as CFString)
			} else {
				guard
					let menuBar: AXUIElement = axApp.getAttribute(named: kAXMenuBarAttribute),
					let targetWindowRep: AXUIElement = menuBar.firstMenuBarItem(named: windowName)
				else {
					Environment.log("[WARNING] Failure retrieving menu bar item representation of window with name <\(windowName)>")
					exit(0)
				}
				NSRunningApplication(processIdentifier: pid_t(applicationPID))?.activate()
				targetWindowRep.press()
			}
			Darwin.exit(EXIT_SUCCESS)
		}
		
		// MARK: Close Window
		static func close(
			applicationPID: Int32 = Environment.applicationPID,
			windowNumber: Int32 = Environment.windowNumber,
			windowName: String = Environment.windowName
		) -> Never {
			let axApp: AXUIElement = AXUIElementCreateApplication(pid_t(applicationPID))
			if let axWindow: AXUIElement = axApp.windowWithinCurrentDesktopSpace(windowNumber: windowNumber),
			   let closeButton: AXUIElement = axWindow.getAttribute(named: kAXCloseButtonAttribute)
			{
				closeButton.press()
			} else {
				guard let targetMenuBar: AXUIElement = axApp.getAttribute(named: kAXMenuBarAttribute) else {
					Environment.log("[WARNING] Failure retrieving menu bar of application with PID <\(applicationPID)>")
					Darwin.exit(EXIT_FAILURE)
				}
				
				guard let targetWindowMenuBarRep: AXUIElement = targetMenuBar.firstMenuBarItem(named: windowName) else {
					Environment.log("[WARNING] Failure retrieving menu bar item representation of window with name <\(windowName)>")
					Darwin.exit(EXIT_FAILURE)
				}
				
				let frontmost: NSRunningApplication? = NSWorkspace.shared.frontmostApplication
				let originAXAppBackup: AXUIElement? = {
					if let frontmost: NSRunningApplication {
						return AXUIElementCreateApplication(frontmost.processIdentifier)
					}
					return nil
				}()
				let originMenuBar: AXUIElement? = originAXAppBackup?.getAttribute(named: kAXMenuBarAttribute)
				/// Get the  menu bar item representing the currently active window.
				/// The currently active window is decorated with a check mark which can be retrieved using the `kAXMenuItemMarkCharAttribute` key.
				let originWindowMenuBarRep: AXUIElement? = originMenuBar?.firstMenuBarItem(where: { $0.isActiveWindowRepresentation })
				/// In some cases the `originWindowMenuBarRep` element becomes invalid after closing the target window.
				/// This may be related to its position in the menu bar list. To compensate for this eventuality, we retrieve a new version of it.
				let originWindowMenuBarRepName: String? = originWindowMenuBarRep?.name
				
				NSRunningApplication(processIdentifier: pid_t(applicationPID))?.activate()
				targetWindowMenuBarRep.press()
				RunLoop.current.run(until: Date.now + TimeInterval(0.5))
				// Now we are on the desktop space that contains the window we want to close
				// We assert that the axWindow can now be matched given the window number
				guard
					let targetAXWindow: AXUIElement = axApp.windowWithinCurrentDesktopSpace(windowNumber: windowNumber),
					let closeButton: AXUIElement = targetAXWindow.getAttribute(named: kAXCloseButtonAttribute)
				else {
					Environment.log("[ERROR] Unable to obtain axWindow with name '\(windowName)' and number '\(windowNumber)'")
					Darwin.exit(EXIT_FAILURE)
				}
				// Close the target window
				closeButton.press()
				
				// Return to the previously focused window if it exists.
				if let originWindowMenuBarRep: AXUIElement {
					frontmost?.activate()
					// Required where the owning app of the closed window is the frontmost app
					if !originWindowMenuBarRep.press(),
					   let originWindowMenuBarRepName: String,
					   let originWindowMenuBarRepRestored: AXUIElement = originAXAppBackup?.firstMenuBarItem(named: originWindowMenuBarRepName)
					{
						originWindowMenuBarRepRestored.press()
					}
				}
			}
			Darwin.exit(EXIT_SUCCESS)
		}
	}
}

// MARK: - AX Helpers
extension AXUIElement {
	
	var name: String? { getAttribute(named: kAXTitleAttribute) }
	var children: [AXUIElement]? { getAttribute(named: kAXChildrenAttribute) }
	var menunBar: AXUIElement? { getAttribute(named: kAXMenuBarAttribute) }
	
	var isActiveWindowRepresentation: Bool {
		if let presentCheckmark: String = getAttribute(named: kAXMenuItemMarkCharAttribute), presentCheckmark == "✓" {
			return true
		}
		return false
	}
	
	func getAttribute<T>(named axAttributeName: String, log: Bool = false) -> T? {
		var value: CFTypeRef?
		let state: AXError = AXUIElementCopyAttributeValue(self, axAttributeName as CFString, &value)
		guard state == .success else {
			if log { Environment.log("[INFO] Failed to get attribute with name '\(axAttributeName)' from AXUIElement (\(state.debugDescription))") }
			return nil
		}
		return value as? T
	}
	
	@discardableResult
	func press() -> Bool {
		let state: AXError = AXUIElementPerformAction(self, kAXPressAction as CFString)
		guard state == .success else {
			Environment.log("[WARNING] Failed to click AXUIElement with name '\(self.name ?? "N/A")' (\(state.debugDescription))")
			return false
		}
		return true
	}
	
	/// If the targeted window is within the active desktop space, we can neglect any concerns about restoring the previous user window / desktop state.
	///
	/// - Note: This function can only succeed if the calling `AXUIElement` is a top-level accessibility object for an application.
	func windowWithinCurrentDesktopSpace(windowNumber: Int32) -> AXUIElement? {
		guard let axWindows: [AXUIElement] = self.getAttribute(named: kAXWindowsAttribute) else {
			return nil
		}
		var axWindowNumber: CGWindowID = 0
		for axWindow in axWindows {
			_AXUIElementGetWindow(axWindow, &axWindowNumber)
			if axWindowNumber == windowNumber {
				return axWindow
			}
		}
		return nil
	}
	
	/// Get the menu bar item matching the givien predicate.
	///
	/// - Note: This function can only succeed if the calling `AXUIElement` is an accessibility object representing the menu bar of an application.
	func firstMenuBarItem(where predicate: (AXUIElement) throws -> Bool) rethrows -> AXUIElement? {
		if let children: [AXUIElement] = getAttribute(named: kAXChildrenAttribute) {
			// Reverse the array to crawl the list starting with Help > Window ... then each sub bar from the bottom
			for child: AXUIElement in children.reversed() {
				if try predicate(child) {
					return child
				}
				if let matched: AXUIElement = try? child.firstMenuBarItem(where: predicate) {
					return matched
				}
			}
		}
		return nil
	}
	
	func firstMenuBarItem(named targetName: String) -> AXUIElement? {
		let fuzzyComponents: [String] = targetName.components(separatedBy: .whitespaces).filter({ $0.count > 1 && $0 != "Edited" })
		return firstMenuBarItem(where: { child in
			if let name: String = child.getAttribute(named: kAXTitleAttribute) {
				if (name == targetName || fuzzyComponents.allSatisfy({ name.contains($0) })) {
					// Skip e.g. 'Dictionary Help'
					if name != "\(targetName) Help" {
						return true
					}
				}
			}
			return false
		})
	}
}

extension AXError: @retroactive CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .notImplemented: return "This error indicates that the function or method is not implemented (this can be returned if a process does not support the accessibility API)."
		case .cannotComplete: return "A fundamental error has occurred, such as a failure to allocate memory during processing."
		case .invalidUIElementObserver: return "The observer for the accessibility object received in this event is invalid."
		case .illegalArgument: return "The value received in this event is an invalid value for this attribute."
		case .apiDisabled: return "API Disabled. Assistive applications are not enabled in System Preferences."
		case .notificationAlreadyRegistered: return "This notification has already been registered for."
		case .notificationUnsupported: return "The notification is not supported by the AXUIElementRef."
		case .parameterizedAttributeUnsupported: return "The parameterized attribute is not supported."
		case .notificationNotRegistered: return "Indicates that a notification is not registered yet."
		case .invalidUIElement: return "The accessibility object received in this event is invalid."
		case .failure: return "A system error occurred, such as the failure to allocate an object."
		case .attributeUnsupported: return "The referenced attribute is not supported."
		case .noValue: return "The requested value or AXUIElementRef does not exist."
		case .actionUnsupported: return "The referenced action is not supported."
		case .notEnoughPrecision: return "Not enough precision."
		case .success: return "No error occurred."
		@unknown default:
			return "An unknown error has occurred (\(self.rawValue))."
		}
	}
}

extension String {
	func droppingSuffix(_ suffix: String = "Edited") -> String {
		if hasSuffix(suffix) {
			return self.dropLast(suffix.count).trimmingCharacters(in: .whitespacesAndNewlines)
		} else {
			return self
		}
	}
	
	func hasSubstring<T: StringProtocol>(_ other: T, options: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]) -> Bool {
		range(of: other, options: options) != nil
	}
}

extension StringProtocol {
	var trimmed: String {
		self.trimmingCharacters(in: .whitespaces)
	}
}

extension Collection {
	func anySatisfy(_ p: (Element) -> Bool) -> Bool {
		return !self.allSatisfy { !p($0) }
	}
}

extension Array where Element: Hashable {
	func deduplicated() -> [Element] {
		var seen: Set<Element> = []
		return filter { seen.insert($0).inserted }
	}
}

extension URL {
	init(file: String) {
		if #available(macOS 14, *) {
			self = URL(filePath: file)
		} else {
			self = URL(fileURLWithPath: file)
		}
	}
}

// MARK: - Runtime validation + caching

extension Set where Element == String {
	static func observedFrauds(fm: FileManager = .default) -> Set<String> {
		guard fm.fileExists(atPath: Environment.runtimeFraudsFile.path) else { return [] }
		var frauds: Set<String> = []
		do {
			let previousFrauds = try String(contentsOf: Environment.runtimeFraudsFile)
			frauds.formUnion(previousFrauds.components(separatedBy: .newlines).map(\.trimmed))
		} catch {
			Environment.log("Error reading previous frauds: \(error)")
		}
		return frauds
	}
}

extension WindowNavigator {
	static let knownFrauds: Set<String> = .observedFrauds()
	
	static let knownFraudsSharedPrefixes: Set<String> = [
		"QLPreviewGenerationExtension",
		"Open and Save Panel Service",
		"QuickLookUIService", // e.g. 'QuickLookUIService (Open and Save Panel Service (Xcode))'
		"LookupViewService",
		"Apparency (", // e.g. Apparency (Finder)
		"Dock Extra",
		"ThemeWidgetControlViewService",
		"LocalAuthenticationRemoteService",
		"WritingToolsViewService"
	]
	
	static let knownFraudsSharedSuffixes: Set<String> = [
		"Networking", "Update Assistant", "Web Content",
		"Quick Look Extension (Finder)", "XPC", "(Plugin)",
		"Helper"
	]
	
	static let localizedWindowMenubarNames: Set<String> = [
		"Window", 		// English
		"Fenster", 		// German
		"Ventana", 		// Spanish
		"Fenêtre", 		// French
		"Finestra", 	// Italian
		"Janela", 		// Portuguese
		"ウィンドウ", 	// Japanese
		"窗口", 			// Chinese (Simplified)
		"視窗", 			// Chinese (Traditional)
		"윈도우", 		// Korean
		"Окно", 		// Russian
		"Fönster", 		// Swedish
		"Vindue", 		// Danish
		"Vindu", 		// Norwegian
		"Venster", 		// Dutch
		"Ikkuna", 		// Finnish
		"Ablak", 		// Hungarian
		"Pencere", 		// Turkish
		"Okno", 		// Polish
		"Fereastră", 	// Romanian
		"Prozor", 		// Croatian
		"Okno", 		// Czech
		"Okno", 		// Slovak
		"Παράθυρο", 	// Greek
		"חלון", 			// Hebrew
		"نافذة", 		// Arabic
		"پنجره", 		// Persian
		"หน้าต่าง", 		// Thai
		"Cửa sổ", 		// Vietnamese
	]
	
	static func remember(frauds: Set<String>, fm: FileManager = .default) {
		let file: URL = Environment.runtimeFraudsFile
		if !fm.fileExists(atPath: file.path) {
			do {
				try fm.createDirectory(at: Environment.dataFolder, withIntermediateDirectories: true)
			} catch {
				Environment.log("[WARNING] Failed to create data folder: \(error)")
				return
			}
		}
		let message: String = frauds.joined(separator: "\n")
		let data: Data = Data("\(message)\n".utf8)
		if let fileHandle = try? FileHandle(forWritingTo: file) {
			fileHandle.seekToEndOfFile()
			fileHandle.write(data)
			fileHandle.closeFile()
		} else {
			try? data.write(to: file, options: .atomicWrite)
		}
	}
}


// MARK: - Main
if Environment.shouldCloseWindow { WindowNavigator.AX.close() }
if Environment.shouldRaiseWindow { WindowNavigator.AX.raise() }
WindowNavigator.permissions()
WindowNavigator.run()
