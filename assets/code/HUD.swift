#!/usr/bin/swift
//
//  HUD.swift
//  Heads-up-display for Notifications.
//  Made for µBib (https://github.com/zeitlings/ubib).
//
//  Created by Patrick Sy on 12/05/2023.
//

import SwiftUI

struct HUDView: View {
	@State private var isShowing: Bool = false
	let text: String = CommandLine.displayText
	let width: CGFloat = CommandLine.hudWidth
	let dismissAfter: TimeInterval = 2.0
	let fade: Double = 0.1

	var body: some View {
		ZStack {
			if isShowing {
				Background()
				HStack {
					Image(systemName: "info.bubble.fill")
						.bold()
						.foregroundColor(.white)
					DisplayText()
				}
			}
		}
		.frame(width: width, height: 40, alignment: .center)
		.transition(.opacity)
		.task {
			withAnimation(.easeIn(duration: fade)) {
				isShowing = true
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + (dismissAfter - fade)) {
				withAnimation(.easeOut(duration: fade)) {
					self.isShowing = false
				}
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + dismissAfter) {
				NSApplication.shared.terminate(nil)
			}
		}
	}
	
	@ViewBuilder
	func Background() -> some View {
		Color(nsColor: NSColor.darkGray.withAlphaComponent(0.9))
			.cornerRadius(20.0)
			.overlay(content: {
				RoundedRectangle(cornerRadius: 20.0)
					.stroke(.primary.opacity(0.1), lineWidth: 1)
			})
	}
	
	@ViewBuilder
	func DisplayText() -> some View {
		Text(text)
			.font(.callout.bold())
			.foregroundColor(.white)
			.padding([.leading, .trailing], 4)
			.frame(alignment: .center)
	}

}

class HUDAppDelegate: NSObject, NSApplicationDelegate {
	var window: NSWindow!
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let dialogView = HUDView()
		window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 400, height: 50),
			styleMask: [.borderless],
			backing: .buffered,
			defer: false
		)
		window.isOpaque = false
		window.hasShadow = false
		window.backgroundColor = NSColor.clear
		window.setFrameAutosaveName("Main Window")
		window.contentView = NSHostingView(rootView: dialogView)
		window.makeKeyAndOrderFront(nil)
		window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
		
		if let screenFrame: NSRect = NSScreen.main?.visibleFrame {
			let windowFrame = window.frame
			let x = screenFrame.midX - windowFrame.width / 2
			let y = screenFrame.midY + (screenFrame.midY / 1.3) // roughly above the alfred frame
			window.setFrameOrigin(NSPoint(x: x, y: y))
		}
		
		NSApplication.shared.activate(ignoringOtherApps: false)
	}
}

extension CommandLine {
	static let displayText: String = arguments.indices.contains(1) ? arguments[1] : "No display text provided"
	static let hudWidth: CGFloat = arguments.indices.contains(2) ? CGFloat(Int(arguments[2]) ?? 280) : 280
}

let app = NSApplication.shared
let delegate = HUDAppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular)
app.run()
