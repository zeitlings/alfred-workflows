#!/usr/bin/swift
//
//  WhatIsIt.swift
//  Inspect Unicode Characters
//
//  Created by Patrick Sy on 27/01/2023.
//

import Foundation.NSJSONSerialization

struct Workflow {
	static let inputv: String = CommandLine.arguments[1]
	static func run() {
		let input: String = inputv.prepared
		let response: Response = input.unicodeScalars
			.reduce(into: .init(), { response, scalar in
				dissect(scalar, &response)
			})
		print(response.output())
	}
}

extension Workflow {
	typealias Mod = Item.Mod
	typealias ModWrapper = Item.ModWrapper
	typealias Text = Item.Text
	
	static func dissect(_ scalar: UnicodeScalar, _ response: inout Response) {
		let codePoint: String = String(scalar.value, radix: 16, uppercase: true)
		let padding: String = String(repeating: "0", count: Swift.max(4 - codePoint.count, 0))
		let full: String = padding + codePoint
		let uni: String = "U+\(full)"
		let hex: String = "0x\(codePoint)"
		let swi: String = "\\u{\(full)}" // swift, es6, js
		let pyg: String = "\\u\(full)"   // python, go
		let htm: String = "&#x\(full);"  // html
		var scalarString: String = .init(scalar)
		let scalarName: String = {
			if let sn: String = scalar.properties.name {
				return sn
			}
			if let an: String = scalar.addedName {
				scalarString = scalar.escaped(asASCII: false)
				return an
			}
			return "[no name found]"
		}()
		let generalCategory: String = scalar.properties.generalCategory.description
		
		let title: String = "\(scalarString)\t\u{203A}\t\(scalarName)"
		let subtitle: String = "\(uni) | \(generalCategory)"
		let arg: String = scalarString
		let text: Text = .init(copy: scalarString)
		let mods: ModWrapper = {
			let cmd: Mod = .init(arg: swi, subtitle: swi)
			let alt: Mod = .init(arg: pyg, subtitle: pyg)
			let ctrl: Mod = .init(arg: htm, subtitle: "\(htm) (HTML entity)")
			let shift: Mod = .init(arg: hex, subtitle: "\(hex) (Hex literal)")
			return ModWrapper(cmd: cmd, alt: alt, ctrl: ctrl, shift: shift)
		}()
		let item: Item = .init(title, subtitle, arg, text, mods)
		response.items.append(item)
	}
}


struct Response: Encodable {
	var items: [Item] = []
	func output(encoder: JSONEncoder = .init()) -> String {
		do {
			let encoded: Data = try encoder.encode(self)
			return String(data: encoded, encoding: .utf8)!
		} catch let error {
			let error: String = error.panicResponse
			print(error)
			fatalError()
		}
	}
}

struct Item: Encodable {
	let title: String
	let subtitle: String
	let arg: String
	let text: Text
	let mods: ModWrapper
	init(_ title: String, _ subtitle: String, _ arg: String, _ text: Text, _ mods: ModWrapper) {
		self.title = title
		self.subtitle = subtitle
		self.arg = arg
		self.text = text
		self.mods = mods
	}
}

extension Item {
	struct Text: Encodable {
		let copy: String
	}
	struct ModWrapper: Encodable {
		let cmd: Mod
		let alt: Mod
		let ctrl: Mod
		let shift: Mod
	}
	struct Mod: Encodable {
		let arg: String
		let subtitle: String
		let valid: Bool = true
	}
}

extension String {
	var prepared: String {
		func cast(_ hex: String) -> Optional<String> {
			guard let decimal: UInt32 = .init(hex, radix: 16),
				  let scalar: UnicodeScalar = .init(decimal) else {
				return nil
			}
			return scalar.description
		}
		
		let converted: Optional<String> = {
			switch true {
			case isSwf: return cast(swtm)
			case isHtm: return cast(swtm)
			case isPyg: return cast(pygx)
			case isHex: return cast(pygx)
			case isRaw:
				/// Prevent inputs like "C" to be cast to hex, which will succeed but is not intended.
				/// Enforce the hex input to always be zero padded to 4 digits if not, e.g. 0x prefixed
				guard count >= 4 else {
					return nil
				}
				return cast(self)
				
			default: return nil
			}
		}()
		
		return converted ?? self
	}
	
	var swtm: String { String(dropFirst(3).dropLast()) } // swift + html
	var pygx: String { String(dropFirst(2)) } // pyg + hex
	var isSwf: Bool { hasPrefix("\\u{") && hasSuffix("}") }
	var isHtm: Bool { hasPrefix("&#x") && hasSuffix(";") }
	var isRaw: Bool { UInt32(self, radix: 16) != nil }
	var isPyg: Bool { hasPrefix("\\u") }
	var isHex: Bool { hasPrefix("0x") }
	
}

extension Error {
	var panicResponse: String {
	"""
	{"items" : [{
		"title" : "Failure encoding response",
		"arg" : "\(localizedDescription)",
		"text" : {
			"copy" : "\(localizedDescription)",
			"largetype" : "\(localizedDescription)"
		},
		"valid" : true
	}]}
	"""
	}
}

extension Unicode.GeneralCategory: CustomStringConvertible {
	public var description: String {
		switch self {
		case .connectorPunctuation: return "Connector Punctuation"
		case .initialPunctuation: return "Initial Punctuation"
		case .paragraphSeparator: return "Paragraph Separator"
		case .closePunctuation: return "Close Punctuation"
		case .finalPunctuation: return "Final Punctuation"
		case .otherPunctuation: return "Other Punctuation"
		case .uppercaseLetter: return "Uppercase Letter"
		case .lowercaseLetter: return "Lowercase Letter"
		case .titlecaseLetter: return "Titlecase Letter"
		case .dashPunctuation: return "Dash Punctuation"
		case .openPunctuation: return "Open Punctuation"
		case .currencySymbol: return "Currency Symbol"
		case .modifierSymbol: return "Modifier Symbol"
		case .modifierLetter: return "Modifier Letter"
		case .nonspacingMark: return "Nonspacing Mark"
		case .spaceSeparator: return "Space Separator"
		case .lineSeparator: return "Line Separator"
		case .enclosingMark: return "Enclosing Mark"
		case .decimalNumber: return "Decimal Number"
		case .letterNumber: return "Letter Number"
		case .otherLetter: return "Other Letter"
		case .spacingMark: return "Spacing Mark"
		case .otherNumber: return "Other Number"
		case .otherSymbol: return "Other Symbol"
		case .mathSymbol: return "Math Symbol"
		case .privateUse: return "Private Use"
		case .unassigned: return "Unassigned"
		case .surrogate: return "Surrogate"
		case .control: return "Control"
		case .format: return "Format"
		@unknown default: return "Unknown"
		}
	}
}

extension UnicodeScalar {
	var addedName: String? { UnicodeScalar.missing[self] }
	static let missing: [UnicodeScalar:String] = [
		"\u{0000}": "NULL",
		"\u{0001}": "START OF HEADING",
		"\u{0002}": "START OF TEXT",
		"\u{0003}": "END OF TEXT",
		"\u{0004}": "END OF TRANSMISSION",
		"\u{0005}": "ENQUIRY",
		"\u{0006}": "ACKNOWLEDGE",
		"\u{0007}": "ALERT",
		"\u{0008}": "BACKSPACE",
		"\u{0009}": "CHARACTER TABULATION",
		"\u{000A}": "LINE FEED (alias: NEW LINE, END OF LINE)",
		"\u{000B}": "LINE TABULATION",
		"\u{000C}": "FORM FEED",
		"\u{000D}": "CARRIAGE RETURN",
		"\u{000E}": "SHIFT OUT (alias: LOCKING-SHIFT ONE)",
		"\u{000F}": "SHIFT IN (alias: LOCKING-SHIFT ZERO)",
		"\u{0010}": "DATA LINK ESCAPE",
		"\u{0011}": "DEVICE CONTROL ONE",
		"\u{0012}": "DEVICE CONTROL TWO",
		"\u{0013}": "DEVICE CONTROL THREE",
		"\u{0014}": "DEVICE CONTROL FOUR",
		"\u{0015}": "NEGATIVE ACKNOWLEDGE",
		"\u{0016}": "SYNCHRONOUS IDLE",
		"\u{0017}": "END OF TRANSMISSION BLOCK",
		"\u{0018}": "CANCEL",
		"\u{0019}": "END OF MEDIUM",
		"\u{001A}": "SUBSTITUTE",
		"\u{001B}": "ESCAPE",
		"\u{001C}": "FILE SEPARATOR | INFORMATION SEPARATOR FOUR",
		"\u{001D}": "GROUP SEPARATOR | INFORMATION SEPARATOR THREE",
		"\u{001E}": "RECORD SEPARATOR | INFORMATION SEPARATOR TWO",
		"\u{001F}": "UNIT SEPARATOR | INFORMATION SEPARATOR ONE",
		"\u{007F}": "DELETE",
		"\u{0080}": "PADDING CHARACTER",
		"\u{0081}": "HIGH OCTET PRESET",
		"\u{0082}": "BREAK PERMITTED HERE",
		"\u{0083}": "NO BREAK HERE",
		"\u{0084}": "INDEX",
		"\u{0085}": "NEXT LINE",
		"\u{0086}": "START OF SELECTED AREA",
		"\u{0087}": "END OF SELECTED AREA",
		"\u{0088}": "CHARACTER TABULATION SET",
		"\u{0089}": "CHARACTER TABULATION WITH JUSTIFICATION",
		"\u{008A}": "LINE TABULATION SET",
		"\u{008B}": "PARTIAL LINE FORWARD",
		"\u{008C}": "PARTIAL LINE BACKWARD",
		"\u{008D}": "REVERSE LINE FEED (alt: REVERSE INDEX)",
		"\u{008E}": "SINGLE SHIFT TWO",
		"\u{008F}": "SINGLE SHIFT THREE",
		"\u{0090}": "DEVICE CONTROL STRING",
		"\u{0091}": "PRIVATE USE ONE",
		"\u{0092}": "PRIVATE USE TWO",
		"\u{0093}": "SET TRANSMIT STATE",
		"\u{0094}": "CANCEL CHARACTER",
		"\u{0095}": "MESSAGE WAITING",
		"\u{0096}": "START OF GUARDED AREA",
		"\u{0097}": "END OF GUARDED AREA",
		"\u{0098}": "START OF STRING",
		"\u{0099}": "SINGLE GRAPHIC CHARACTER INTRODUCER",
		"\u{009A}": "SINGLE CHARACTER INTRODUCER",
		"\u{009B}": "CONTROL SEQUENCE INTRODUCER",
		"\u{009C}": "STRING TERMINATOR",
		"\u{009D}": "OPERATING SYSTEM COMMAND",
		"\u{009E}": "PRIVACY MESSAGE",
		"\u{009F}": "APPLICATION PROGRAM COMMAND",
	]
}


Workflow.run()
