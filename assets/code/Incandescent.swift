#!/usr/bin/swift
//
//  Incandescent.swift
//  Adjust the Keyboard Brightness
//
//  Created by Patrick Sy on 20/04/2023.
//

import Quartz

enum Key: UInt {
	case down = 0xa00
	case up = 0xb00
	
	func adjusting(_ brightness: UInt32) {
		if let event: NSEvent = .otherEvent(
			with: .systemDefined,
			location: .zero,
			modifierFlags:  .init(rawValue: rawValue),
			timestamp: 0,
			windowNumber: 0,
			context: nil,
			subtype: 8,
			data1: Int(brightness << 16 | UInt32(rawValue)),
			data2: -1
		), let cgEvent: CGEvent = event.cgEvent
		{
			cgEvent.post(tap: .cgSessionEventTap)
		}
	}
}

Task.detached(operation: {
	let argument: String = CommandLine.arguments[1]
	let illumination: UInt32 = {
		switch argument.first {
		case "+", ">": return 21 // increase
		case "-", "<": return 22 // decrease
		default: exit(0)
		}
	}()
	DispatchQueue.main.async {
		Key.down.adjusting(illumination)
		Key.up.adjusting(illumination)
	}
})

RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))


