#!/usr/bin/swift
//  Alfred Roman Numeral Converter
//  Created by Patrick Sy on 26/01/2023.

struct Workflow {
	static let argument: String = CommandLine.arguments[1].uppercased()
	static let gatekeeper: Regex = try! Regex("^(?=[MDCLXVI])M*(C[MD]|D?C{0,3})(X[CL]|L?X{0,3})(I[XV]|V?I{0,3})$")
	static let romanNumerals: ContiguousArray<[UInt8]> = [[77],[67,77],[68],[67,68],[67],[88,67],[76],[88,76],[88],[73,88],[86],[73,86],[73]]
	static let arabicNumerals: ContiguousArray<Int> = [1000,900,500,400,100,90,50,40,10,9,5,4,1]
	static let prototype: ContiguousArray<UInt8> = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] // Roman 3888, 15 chars
	
	static func run() {
		let conv: String = Int(argument)?.romanRepresentation ?? argument.decimalRepresentation
		let resp: String = "{\"items\":[{\"title\":\"\(conv)\",\"arg\":\"\(conv)\",\"text\":{\"copy\":\"\(conv)\",\"largetype\":\"\(conv)\"},\"valid\":true}]}"
		print(resp)
	}
}

extension Int {
	var romanRepresentation: String {
		guard self > 0 && self < 4000 else {
			return "Invalid Number"
		}
		var k: Int = 0
		var offset: Int = 0
		var check: Int = self
		var upper: Int = 0
		var roman: ContiguousArray<UInt8> = Workflow.prototype
		while k < 13 {
			let count: Int = check / Workflow.arabicNumerals[k]
			if count != 0 {
				let byteCount: Int = Workflow.romanNumerals[k].count
				let capacity: Int = count &* byteCount
				let alpha: [UInt8] = .init(unsafeUninitializedCapacity: capacity)
				{ buffer, initializedCount in
					var i: Int = 0
					while i < capacity {
						var j: Int = 0
						while j < byteCount {
							buffer[i] = Workflow.romanNumerals[k][j]
							j &+= 1
							i &+= 1
						}
					}
					initializedCount = capacity
				}
				var l: Int = 0
				while l < capacity {
					roman[l&+offset] = alpha[l]
					l &+= 1
					upper &+= 1
				}
				offset &+= capacity
			}
			check = check % Workflow.arabicNumerals[k]
			k &+= 1
		}
		return String(decoding: roman[..<upper], as: UTF8.self)
	}
}

extension String {
	var decimalRepresentation: String {
		guard self.firstMatch(of: Workflow.gatekeeper) != nil else {
			return "Invalid Numeral"
		}
		var r: Int = 0
		var max: Int = 0
		for s: UnicodeScalar in unicodeScalars.reversed() {
			let v: Int = s.val
			max = Swift.max(v, max)
			r &+= v == max ? v : -v
		}
		return String(r)
	}
}

extension UnicodeScalar {
	var val: Int {
		switch self {
		case "M": return 1000
		case "D": return 500
		case "C": return 100
		case "L": return 50
		case "X": return 10
		case "V": return 5
		case "I": return 1
		default: return 0
		}
	}
}

Workflow.run()
