#!/usr/bin/swift
//
//  DeviceBattery.swift
//  Parse Script Filter Responses
//  From `ioreg` and `system_profiler`
//
//  Created by Patrick Sy on 29/04/2023.
//  Updated 11/02/2025 (macOS 15)
//  Updated 21/02/2025
//

if #available(macOS 13.0, *) {

	let profiler: String = CommandLine.arguments[1] // `system_profiler`
	let devices: String = CommandLine.arguments[2]  // `ioreg`

    struct Device {
        let name: String
        let address: String
        var batteryLevel: Int?
        var minorType: String?
        var isAirPods: Bool = false
        var airPodsLevels: (left: String, right: String, case: String)?

        var icon: String {
            if let minorType: String {
                return minorType[minorType.startIndex...].icon
            }
            return name[name.startIndex...].icon
        }

        var alfredItem: String {
            if isAirPods, let levels = airPodsLevels {
                return "{\"title\":\"\(name)\",\"subtitle\":\"􀹬 \(levels.case) 􀲎 \(levels.left) 􀲍 \(levels.right)\",\"valid\":\"false\",\"icon\":{\"path\":\"icons/airpodspro.png\"}}"
            }
            return "{\"title\":\"\(name)\",\"subtitle\":\"\(batteryLevel ?? 0)% \((batteryLevel ?? 0).battery)\",\"valid\":\"false\",\"icon\":{\"path\":\"\(icon)\"}}"
        }
    }

    func parseSystemProfiler(_ input: String) -> [String: Device] {
        var devices: [String: Device] = [:]
        guard let connected = input.connectedDevices else { return devices }
        let deviceEntries = connected.split(separator: #/>\n/#)
        for entry in deviceEntries {
            if entry.contains("AirPods") {
                if let nameMatch = entry.firstMatch(of: #/^\s+(.+):\n/#),
                   let addressMatch = entry.firstMatch(of: #/Address:\s+([0-9A-F:]+)/#),
                   let leftBattery = entry.firstMatch(of: #/Left Battery Level:\s+(\d+%)/#),
                   let rightBattery = entry.firstMatch(of: #/Right Battery Level:\s+(\d+%)/#)
                {
                    let name = String(nameMatch.output.1)
                    let address = String(addressMatch.output.1).lowercased()
                    let caseBattery: String = entry.firstMatch(of: #/(?:Case Battery Level:\s)(\d?\d?\d\%)/#).map({ String($0.output.1) }) ?? "n/A"
                    var device = Device(name: name, address: address)
                    device.isAirPods = true
                    device.airPodsLevels = (
                        left: String(leftBattery.output.1),
                        right: String(rightBattery.output.1),
                        case: caseBattery // Case battery level might not be available anymore
                    )
                    devices[address] = device
                }
            } else if let nameMatch = entry.firstMatch(of: #/^\s+(.+):\n/#),
                      let addressMatch = entry.firstMatch(of: #/Address:\s+([0-9A-F:]+)/#)
            {
                let batteryMatch = entry.firstMatch(of: #/Battery Level:\s(\d?\d?\d)/#)
                let typeMatch = entry.firstMatch(of: #/Type:\s+(.+)/#)
                let name: String = String(nameMatch.output.1)
                let address: String = String(addressMatch.output.1).lowercased()
                let battery: Optional<Int> = batteryMatch.map({ Int($0.output.1) }) ?? nil
                let type: Optional<String> = typeMatch.map({ String($0.output.1) }) ?? nil
                devices[address] = Device(name: name, address: address, batteryLevel: battery, minorType: type)
            }
        }
        return devices
    }

    func parseIOReg(_ input: String) -> [String: Int] {
        var batteryLevels: [String: Int] = [:]
        let devices = input.split(separator: #/\+-o/#)
        for device in devices {
            if let addressMatch = device.firstMatch(of: #/"DeviceAddress"\s+=\s+"([0-9a-f-]+)"/#),
               let batteryMatch = device.firstMatch(of: #/"BatteryPercent"\s+=\s+(\d+)/#) {
                let address = String(addressMatch.output.1).replacing("-", with: ":")
                if let battery = Int(batteryMatch.output.1) {
                    batteryLevels[address] = battery
                }
            } else if let serialMatch = device.firstMatch(of: #/"SerialNumber"\s+=\s+"([0-9A-F:]+)"/#),
                      let batteryMatch = device.firstMatch(of: #/"BatteryPercent"\s+=\s+(\d+)/#) {
                let address = String(serialMatch.output.1).lowercased()
                if let battery = Int(batteryMatch.output.1) {
                    batteryLevels[address] = battery
                }
            }
        }
        return batteryLevels
    }

    func processDeviceInfo(profiler: String, ioreg: String) -> String {
        var devices: [String: Device] = parseSystemProfiler(profiler)
        let batteryLevels: [String: Int] = parseIOReg(ioreg)

        for (address, battery) in batteryLevels {
            if var device: Device = devices[address] {
                device.batteryLevel = battery
                devices[address] = device
            }
        }

        let items = devices.values
            .sorted { $0.name < $1.name }
            .filter { $0.isAirPods || $0.batteryLevel != nil }
            .map { $0.alfredItem }

        guard !items.isEmpty else {
            return "{\"items\":[{\"title\":\"No Bluetooth devices connected.\"}]}"
        }

        return "{\"items\":[\(items.joined(separator: ","))],\"rerun\":2}"
    }

	let response = processDeviceInfo(profiler: profiler, ioreg: devices)
	print(response, terminator: "")

} else {
	print("{\"items\":[{\"title\":\"The workflow requires macOS 13.0 or later\"}]}", terminator: "")
}

extension Substring {

	func has(substring: String) -> Bool {
		firstRange(of: substring) != nil
	}

	var icon: String {
		switch true {
		case firstRange(of: #/[Kk]ey/#)   != nil: return "icons/keyboard.png"
		case firstRange(of: #/[Tt]rack/#) != nil: return "icons/trackpad.png"
		case firstRange(of: #/Magic Mo/#) != nil: return "icons/mmouse.png"
		case firstRange(of: #/[Mm]ouse/#) != nil: return "icons/mouse.png"
		case firstRange(of: #/Head/#) != nil: return "icons/headphones.png" // TODO: headset.png
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

extension String {
	var connectedDevices: Substring? {
		guard let lowerbound: String.Index = firstRange(of: "Connected:")?.upperBound,
			  let upperbound: String.Index = firstRange(of: "Not Connected:")?.lowerBound,
			  lowerbound <= upperbound
		else {
			return nil
		}

		return self[lowerbound..<upperbound]
	}
}
