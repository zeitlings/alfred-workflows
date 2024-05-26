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

import AppKit


// MARK: - WindowNavigator
struct WindowNavigator {
	static let directive: Directive = .init(rawValue: CommandLine.arguments[1])!
	private static let stdOut: FileHandle = .standardOutput
	
	static let frontMostApplicationName: String? = {
		if let frontMostAppName: String = onScreenWindows.first(where: { $0.windowIsOnScreen })?.owningApplicationName {
			return frontMostAppName
		}
		return nil
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
	
	static func run() {
		let items: [Item]
		switch directive {
		case .navigator: items = relativeWindows.map({ $0.alfredItem })
		case .switcher:  items = onScreenWindows.map({ $0.alfredItem })
		}
		yield(items: items.isEmpty ? [.noWindows] : items)
	}
	
	
	/// Outputs the given items as an Alfred script filter response and terminates the program.
	///
	/// This function encodes the provided list of `Item` objects into a response, writes the
	/// encoded response to the standard output, and then terminates the program.
	///
	/// - Parameters:
	///   - items: An array of `Item` objects to be included in the response.
	private static func yield(items: [Item]) -> Never {
		try? stdOut.write(contentsOf: Response(items: items).encoded())
		Darwin.exit(EXIT_SUCCESS)
	}
	
	
	/// Verifies screen capture access for the application and requests access if necessary.
	///
	/// This function checks if the application has the required screen capture permissions.
	/// If the permissions are not already granted, it will request them and then terminate the program.
	///
	/// - Returns: `nil` if screen capture access is already granted. If access is not granted,
	///   the function requests access and terminates the program, thus it does not return in this case.
	@discardableResult
	static func verify() -> Never? {
		guard CGPreflightScreenCaptureAccess() else {
			CGRequestScreenCaptureAccess()
			Darwin.exit(EXIT_SUCCESS)
		}
		return nil
	}

	
	// MARK: Raise / Close Window
	/// Performs an action on a specified window of an application and then exits the program.
	///
	/// This function identifies a window of a specified application by its process identifier (PID) and window number.
	/// It then performs the specified action (raise or close) on that window to either raise a specific window to the foreground
	/// or close a specific window in the background.
	///
	/// - Parameters:
	///   - action: The action to be performed on the window. This can be `.raise` to bring the window to the front,
	///             or `.close` to close the window.
	///   - appPID: The process identifier (PID) of the application that owns the window to be raised. Defaults to the passed in PID via `Environment.applicationPID`.
	///   - windowNumber: The window number of the target window. Defaults to the passed in window number via `Environment.windowNumber`.
	///
	/// - Returns: `Never`, i.e. nothing as the function terminates the program after execution.
	static func window(_ action: AXAction, appPID: Int32 = Environment.applicationPID, windowNumber: Int32 = Environment.windowNumber) -> Never {
		let axApp = AXUIElementCreateApplication(pid_t(appPID))
		var axWindows: AnyObject?
		AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, &axWindows)
		for axWindow in (axWindows as! [AXUIElement]) {
			var axWindowNumber: CGWindowID = 0
			_AXUIElementGetWindow(axWindow, &axWindowNumber)
			guard axWindowNumber == windowNumber else {
				continue
			}
			switch action {
			case .raise:
				let app = NSRunningApplication(processIdentifier: pid_t(appPID))
				app?.activate(options: .activateIgnoringOtherApps)
				AXUIElementPerformAction(axWindow, kAXRaiseAction as CFString)
				
			case .close:
				var buttonRef: CFTypeRef?
				AXUIElementCopyAttributeValue(axWindow, kAXCloseButtonAttribute as CFString, &buttonRef)
				if let button: CFTypeRef = buttonRef {
					AXUIElementPerformAction(button as! AXUIElement, kAXPressAction as CFString)
				}
			}
		}
		Darwin.exit(EXIT_SUCCESS)
	}
	
	enum AXAction {
		case raise
		case close
	}

}

if Environment.shouldCloseWindow {
	WindowNavigator.window(.close)
}

if Environment.shouldRaiseWindow {
	WindowNavigator.window(.raise)
}
WindowNavigator.verify()
WindowNavigator.run()




// MARK: - Item
struct Item: Codable {
	let title: String
	let subtitle: String
	let arg: [String]?
	let variables: [String: String]?
	let icon: [String: String]
	let autocomplete: String?
	let match: String?
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
			}
			
		}()
		return .init(
			title: "No windows.",
			subtitle: subtitle,
			arg: nil,
			variables: nil,
			icon: ["path":"icons/info.png"],
			autocomplete: nil,
			match: nil,
			valid: false
		)
	}()
}

// MARK: - Response
struct Response: Codable {
	let items: [Item]
	let variables: [String:String]?
	
	init(
		items: [Item],
		variables: [String : String]? = WindowNavigator.directive == .switcher ? ["trigger":"raise_window"] : nil
	) {
		self.items = items
		self.variables = variables
	}
	
	func encoded() -> Data {
		try! JSONEncoder().encode(self)
	}
}

// MARK: - WindowWrapper
struct WindowWrapper: CustomDebugStringConvertible {
	//let raw: [String: Any]
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
	
	var windowTitlePrefix: String {
		windowTitle.components(separatedBy: .whitespaces).first!
	}
	
	/// If we succeed in creating a composited image representation of the window,
	/// then it is an actual window visible somewhere on some workspace.
	var isValidWindow: Bool {
		CGWindowListCreateImage(self.windowBounds, CGWindowListOption.optionIncludingWindow, UInt32(windowNumber), CGWindowImageOption.onlyShadows) != nil
	}
	
	init?(_ info: [String : Any]) {
		guard
			let owningApplicationName = info[kCGWindowOwnerName as String] as? String,
			let owningApplicationPID = info[kCGWindowOwnerPID as String] as? Int32,
			let applicationPath = NSRunningApplication(processIdentifier: owningApplicationPID)?.bundleURL?.path,
			let windowNumber = info[kCGWindowNumber as String] as? Int32,
			let windowLayer = info[kCGWindowLayer as String] as? Int, // == 0
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
		
		guard windowLayer == 0 else { return nil } // isWindow
		guard !windowTitle.isEmpty || windowHeight > 70 else { return nil }
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
		self.windowBackingType = .init(rawValue: windowBackingType)!
		self.windowSharingState = .init(rawValue: windowSharingState)!
		self.windowMemoryUsage = windowMemoryUsage
		//self.raw = info
	}
	
	// kCGWindowStoreType
	enum WindowBackingType: UInt32, CustomStringConvertible {
		case backingStoreRetained = 0
		case backingStoreNonretained = 1
		case backingStoreBuffered = 2
		
		var description: String {
			switch self {
			case .backingStoreRetained: return "Backing Store Retained"
			case .backingStoreNonretained: return "Backing Store Nonretained"
			case .backingStoreBuffered: return "Backing Store Buffered"
			}
		}
	}
	
	// kCGWindowSharingState
	enum WindowSharingState: Int32, CustomStringConvertible {
		case none = 1
		case readOnly = 2
		case readWrite = 3
		
		var description: String {
			switch self {
			case .none: return "none"
			case .readOnly: return "read only"
			case .readWrite: return "read-write"
			}
			
		}
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
			arg: [String(owningApplicationPID), windowTitlePrefix],
			variables: [
				"app_pid": "\(owningApplicationPID)",
				"app_name": "\(owningApplicationName)",
				"win_num": "\(windowNumber)"
			],
			icon: ["type": "fileicon", "path": applicationPath],
			autocomplete: nil,
			match: "\(windowTitle) \(owningApplicationName)",
			valid: true
		)
	}
	
}

// MARK: - Environment
struct Environment {
	static private let env: [String:String] = ProcessInfo.processInfo.environment
	static let shouldRaiseWindow: Bool = env["trigger"] == "raise_window" && env["app_pid"] != nil && env["win_num"] != nil
	static let shouldCloseWindow: Bool = env["trigger"] == "close_window" && env["app_pid"] != nil && env["win_num"] != nil
	static let applicationPID: Int32 = Int32(env["app_pid"]!)!
	static let windowNumber: Int32 = Int32(env["win_num"]!)!
	static let includeFrontmostWindow: Bool = env["include_top_win"] == "1"
	
	static private let stdErr: FileHandle = .standardError
	static func log(_ message: String) {
		try? stdErr.write(contentsOf: Data("\(message)\n".utf8))
	}
}

// MARK: - Directive
enum Directive: String {
	case navigator
	case switcher
}
