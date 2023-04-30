#!/usr/bin/swift
//
//  Dialog.swift
//  GUI Input Experiment
//
//  Proof of concept for using NSWindow and SwiftUI components
//  to get user input through a graphical prompt and then use it
//  in the Alfred app - or on the command line.
//
//  Created by Patrick Sy on 30/04/2023.
//

import SwiftUI

struct Dialog: View {
	@State var title: String = ""
	@State var text: String = ""
	@State var max: String = ""
	@State var min: String = ""
	@State var long: String = ""
	@State var choice: Choice = .A
	@State var toggle: Bool = false
	@State private var date = Date()
	
  var body: some View {
	  VStack {
		  Title(text: "Enter the info you want to use in Alfred")
		  Row(text: "Title", input: $title)
		  Row(text: "Subtitle", input: $text)
		  Row(text: "Maximum", input: $max)
		  Row(text: "Minimum", input: $min)
		  Row(text: "Longer descriptor", input: $long)
		  Selector(info: "Picker", option: $choice)
		  
		  Toggle("Send Copy", isOn: $toggle)
			  .toggleStyle(SwitchToggleStyle())
			  .frame(width: 325, alignment: .leading)
		  
		  Buttons()
	  }
	  .padding()
	  .frame(width: 460)
  }
	
	@ViewBuilder
	func Title(icon: String = "aqi.medium", text: String) -> some View {
		HStack {
			Image(systemName: icon)
				.font(Font.largeTitle)
				.foregroundColor(.blue)
				.padding(.trailing, 10)
			Text(text).font(.title2)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
	
	@ViewBuilder
	func Buttons() -> some View {
		HStack {
			Button(role: .cancel) {
				print("canceled")
				NSApplication.shared.terminate(nil)
			} label: {
				Text("Cancel")
			}
			// ===---------------------------------------------------------------=== //
			// MARK: - Define here what should be returned
			// ===---------------------------------------------------------------=== //
			Button {
				print("\(title)\t\(text)\t\(max)\t\(min)\t\(long)\t\(choice)\t\(toggle.description)")
				NSApplication.shared.terminate(nil)
			} label: {
				Text("Proceed")
			}
		}
		.frame(maxWidth: .infinity, alignment: .trailing)
		.padding(.top, 10)
	}
}

struct Row: View {
	let text: String
	@Binding var input: String
	
	var body: some View {
		HStack {
			Text(text)
			TextField(text, text: $input)
				.frame(maxWidth: 300)
		}
		.frame(maxWidth: .infinity, alignment: .trailing)
	}
}

enum Choice: String, CaseIterable {
	var id: Self { self }
	case A = "This is option A"
	case B = "This is option B"
	case C = "This is option C"
}

struct Selector: View {
	let info: String
	@Binding var option: Choice
	var body: some View {
		HStack {
			Text(info)
			Picker("", selection: $option, content: {
				Text(Choice.A.rawValue).tag(Choice.A)
				Text(Choice.B.rawValue).tag(Choice.B)
				Text(Choice.C.rawValue).tag(Choice.C)
			})
			.frame(width: 310)
		}
		.frame(maxWidth: .infinity, alignment: .trailing)
	}
}

class DialogAppDelegate: NSObject, NSApplicationDelegate {
	var window: NSWindow!
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let dialogView = Dialog()
		window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 400, height: 350),
			styleMask: [.titled, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered,
			defer: false
		)
		window.center()
		window.setFrameAutosaveName("Main Window")
		window.contentView = NSHostingView(rootView: dialogView)
		window.makeKeyAndOrderFront(nil)
		NSApplication.shared.activate(ignoringOtherApps: true)
	}
}


let app = NSApplication.shared
let delegate = DialogAppDelegate()
app.delegate = delegate
app.setActivationPolicy(.regular) // so we can bring the window back when it goes to the background
app.run()


