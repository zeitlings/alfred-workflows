#!/usr/bin/swift
//
//  DeviceBattery.swift
//  Parse Script Filter Responses
//  From `ioreg` and `system_profiler`
//
//  Created by Patrick Sy on 29/04/2023.
//

if #available(macOS 13.0, *) {

	let airpods: String = CommandLine.arguments[1]
	let devices: String = CommandLine.arguments[2]
	
	func getAirpodsInfo(profile: String) -> String? {
		guard let lowerbound: String.Index = profile.firstRange(of: "Connected:")?.upperBound,
			  let upperbound: String.Index = profile.firstRange(of: "Not Connected:")?.lowerBound else {
			return nil
		}
		let connected: Substring = airpods[lowerbound..<upperbound]
		if let product = connected.firstMatch(of: #/Air\w+\s?\w+/#),
		   let caseBatteryLevel = connected.firstMatch(of: #/(?:Case Battery Level:\s)(\d?\d?\d\%)/#),
		   let leftBatteryLevel = connected.firstMatch(of: #/(?:Left Battery Level:\s)(\d?\d?\d\%)/#),
		   let rightBatteryLevel = connected.firstMatch(of: #/(?:Right Battery Level:\s)(\d?\d?\d\%)/#)
		{
			let productName: Substring = connected[product.range]
			let caseBatteryPercent: Substring = caseBatteryLevel.output.1
			let leftBatteryPercent: Substring = leftBatteryLevel.output.1
			let rightBatteryPercent: Substring = rightBatteryLevel.output.1
			// TODO: Identify versions
			let item: String = "{\"title\":\"\(productName)\",\"subtitle\":\"􀹬 \(caseBatteryPercent) 􀲎 \(leftBatteryPercent) 􀲍 \(rightBatteryPercent)\",\"valid\":\"false\",\"icon\":{\"path\":\"icons/airpodspro.png\"}}"
			return item
		}
		return nil
	}
	
	func getBluetoothDeviceInfo(ioreg: String) -> String? {
		let devices: [Substring] = ioreg.split(separator: #/\+-o/#, omittingEmptySubsequences: true)
		let items: [String] = devices.reduce(into: []) { partialResult, deviceInfo in
			if let product = deviceInfo.firstMatch(of: #/(?:Product\" = )\"(.+)\"/#),
			   let battery = deviceInfo.firstMatch(of: #/(?:BatteryPercent\" = )(\d+)/#)
			{
				let productName: Substring = product.output.1
				let batterPercent: Substring = battery.output.1
				let battery: String = Int(batterPercent)!.battery
				let icon: String = productName.icon
				partialResult.append("{\"title\":\"\(productName)\",\"subtitle\":\"\(batterPercent)% \(battery)\",\"valid\":\"false\",\"icon\":{\"path\":\"\(icon)\"}}")
			}
		}
		guard !items.isEmpty else { return nil }
		return items.joined(separator: ",")
	}
	
	let infoAirpods: String? = getAirpodsInfo(profile: airpods)
	let infoDevices: String? = getBluetoothDeviceInfo(ioreg: devices)
	
	var response: String = "{\"items\":["
	switch (infoAirpods, infoDevices) {
	case (.some(let a), .some(let d)): response += "\(a),\(d)"
	case (.some(let a), .none): response += a
	case (.none, .some(let d)): response += d
	case (.none, .none): response += "{\"title\":\"No Bluetooth devices connected\"}"
	}
	response += "],\"rerun\":4}"
	print(response)

} else {
	print("{\"items\":[{\"title\":\"The workflow requires macOS 13.0 or later\"}]}")
}


extension Substring {
	// TODO: Determine `Minor Type` and hash with `DeviceAddress` (profiler input)
	var icon: String {
		switch true {
		case firstRange(of: #/[Kk]ey/#)   != nil: return "icons/keyboard.png"
		case firstRange(of: #/[Tt]rack/#) != nil: return "icons/trackpad.png"
		case firstRange(of: #/Magic Mo/#) != nil: return "icons/mmouse.png"
		case firstRange(of: #/[Mm]ouse/#) != nil: return "icons/mouse.png"
		default: return ""
		}
	}
}

extension Int {
	var battery: String {
		switch true {
		case 90..<101 ~= self: return "􀛨"
		case 60..<90  ~= self: return "􀺸"
		case 35..<60  ~= self: return "􀺶"
		case 10..<35  ~= self: return "􀛩"
		default: return "􀛪"
		}
	}
}

