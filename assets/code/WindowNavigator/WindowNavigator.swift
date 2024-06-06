//
//  WindowNavigator.swift
//  Window Navigator Alfred Workflow
//
//  Navigate to any window of the active app over all desktop spaces or
//  Switch to a window open in the current desktop space.
//  <https://github.com/zeitlings/alfred-workflows>
//
//  Created by Patrick Sy on 21/05/2024.
//

import Foundation
import ApplicationServices

// MARK: - WindowNavigator
struct WindowNavigator {
	static let directive: Directive = .init(rawValue: CommandLine.arguments[1])!
	private static let stdOut: FileHandle = .standardOutput
	
	static let frontMostApplicationName: String? = {
		onScreenWindows.first(where: { $0.windowIsOnScreen })?.owningApplicationName
	}()
	
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
		let windows: [WindowWrapper] = onScreenWindows.compactMap({ WindowWrapper($0) })
		switch directive {
		case .navigator: return windows
		case .switcher:  return Environment.includeFrontmostWindow ? windows : .init(windows.dropFirst())
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
			//preconditionFailure("Unable to retrieve the frontmost window.")
			yield(items: [.noWindows])
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
			.filter({ $0.isValidWindow })
		
		return windows
	}()
	
	private static let completeWindows: [WindowWrapper] = {
		let globalWindowList: CFArray? = CGWindowListCopyWindowInfo([.optionAll, .excludeDesktopElements], kCGNullWindowID)
		guard let allWindows = globalWindowList as? [[String: Any]] else {
			preconditionFailure("Unable to retrieve global window list")
		}
		
		// TODO: Group the apps together?
		var windows: [WindowWrapper] = allWindows.compactMap({ .init($0) }).filter({ $0.isValidWindow })
		if
			!Environment.includeFrontmostWindow,
			let first: WindowWrapper = onScreenWindows.first,
			let index: Int = windows.firstIndex(where: { $0.windowNumber == first.windowNumber })
		{
			windows.remove(at: index)
		}
		return windows
	}()
	
	static func run() {
		let items: [Item]
		switch directive {
		case .navigator: items = relativeWindows.map({ $0.alfredItem })
		case .switcher:  items = onScreenWindows.map({ $0.alfredItem })
		case .global:    items = completeWindows.map({ $0.alfredItem })
		}
		yield(items: items.isEmpty ? [.noWindows] : items)
	}
	
	/// Outputs the given items as an Alfred script filter response and terminates the program.
	///
	/// - Parameters:
	///   - items: An array of `Item` objects to be included in the response.
	private static func yield(items: [Item]) -> Never {
		try? stdOut.write(contentsOf: Response(items: items).encoded())
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


// MARK: - Item
struct Item: Codable {
	let title: String
	let subtitle: String
	let arg: [String]?
	let variables: [String: String]?
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
	let items: [Item]
	let variables: [String:String]?
	
	init(items: [Item]) {
		self.items = items
		self.variables = ["trigger":"raise_window"]
	}
	
	func encoded() -> Data {
		try! JSONEncoder().encode(self)
	}
}

// MARK: - WindowWrapper
struct WindowWrapper: CustomDebugStringConvertible {
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
	
	/// If we succeed in creating a composited image representation of the window, then it is an actual window visible somewhere on some workspace.
	var isValidWindow: Bool {
		CGWindowListCreateImage(self.windowBounds, CGWindowListOption.optionIncludingWindow, UInt32(windowNumber), CGWindowImageOption.onlyShadows) != nil
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
		return Item(
			title: windowTitle,
			subtitle: owningApplicationName,
			arg: nil,
			variables: [
				"app_pid": "\(owningApplicationPID)",
				"app_name": "\(owningApplicationName)",
				"win_num": "\(windowNumber)",
				"win_name": "\(windowTitle)"
			],
			icon: ["type": "fileicon", "path": applicationPath],
			autocomplete: nil,
			match: "\(windowTitle) \(owningApplicationName)",
			text: ["largetype":"\(windowTitle)\n\(owningApplicationName)"],
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
	static let ignoredWindowNames: [String]? = env["ignored_window_names"]?
		.split(separator: ",")
		.map({ $0.trimmingCharacters(in: .whitespaces) })
	
	static private let stdErr: FileHandle = .standardError
	static func log(_ message: String) {
		try? stdErr.write(contentsOf: Data("\(message)\n".utf8))
	}
}

// MARK: - Directive
enum Directive: String {
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
				NSRunningApplication(processIdentifier: pid_t(applicationPID))?.activate(options: .activateIgnoringOtherApps)
				AXUIElementPerformAction(axWindow, kAXRaiseAction as CFString)
			} else {
				guard
					let menuBar: AXUIElement = axApp.getAttribute(named: kAXMenuBarAttribute),
					let targetWindowRep: AXUIElement = menuBar.firstMenuBarItem(named: windowName)
				else {
					//Environment.log("[WARNING] Failure retrieving menu bar of application with PID <\(applicationPID)>")
					Environment.log("[WARNING] Failure retrieving menu bar item representation of window with name <\(windowName)>")
					exit(0)
				}
				NSRunningApplication(processIdentifier: pid_t(applicationPID))?.activate(options: .activateIgnoringOtherApps)
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
				
				guard let targetWindowMenuBarRep = targetMenuBar.firstMenuBarItem(named: windowName) else {
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
				/// This may be related to its position in the menu bar list. To prevent this eventuality, we retrieve a new version of it.
				let originWindowMenuBarRepName: String? = originWindowMenuBarRep?.name
				
				NSRunningApplication(processIdentifier: pid_t(applicationPID))?.activate(options: .activateIgnoringOtherApps)
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
					frontmost?.activate(options: .activateIgnoringOtherApps)
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
	var isActiveWindowRepresentation: Bool {
		if let presentCheckmark: String = getAttribute(named: kAXMenuItemMarkCharAttribute), presentCheckmark == "✓" {
			return true
		}
		return false
	}
	var name: String? { getAttribute(named: kAXTitleAttribute) }
	
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
	
	/// Get the menu bar item matching the giving the predicate.
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

extension AXError: CustomDebugStringConvertible {
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

// MARK: - Main
if Environment.shouldCloseWindow { WindowNavigator.AX.close() }
if Environment.shouldRaiseWindow { WindowNavigator.AX.raise() }
WindowNavigator.permissions()
WindowNavigator.run()
