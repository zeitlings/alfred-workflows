#!/usr/bin/swift
//
//  ColorPicker.swift
//  Color Picker Alfred Workflow
//
//  Created by Patrick Sy on 20/08/2023.
//


import AppKit

guard #available(OSX 10.15, *) else {
	print("macOS 10.15 or greater required", terminator: "")
	exit(1)
}

let cache: String = ProcessInfo.processInfo.environment["alfred_workflow_cache"]!
let showHSL: Bool = ProcessInfo.processInfo.environment["show_hsl"] == "1"
let showNSColor: Bool = ProcessInfo.processInfo.environment["show_nscolor"] == "1"
let showRGBa: Bool = ProcessInfo.processInfo.environment["show_rgba"] == "1"

struct Color {
	let red: Int
	let blue: Int
	let green: Int
	let alpha: Int
	let color: NSColor
	
	init(nsColor c: NSColor) {
		self.red =   lroundf(Float(c.redComponent) * 0xFF)
		self.blue =  lroundf(Float(c.blueComponent) * 0xFF)
		self.green = lroundf(Float(c.greenComponent) * 0xFF)
		self.alpha = lroundf(Float(c.alphaComponent) * 0xFF)
		self.color = c
	}
	
	var rgb: String { "rgb(\(red), \(green), \(blue))" }
	var rgba: String { "rgb(\(red), \(green), \(blue), \(alpha))" }
	var hex: String {
		[\Color.red, \Color.green, \Color.blue].map({
			String(self[keyPath: $0], radix: 16)
		}).joined().uppercased()
	}
	
	var hsl: String {
		let red: CGFloat = CGFloat(color.redComponent)
		let green: CGFloat = CGFloat(color.greenComponent)
		let blue: CGFloat = CGFloat(color.blueComponent)
		
		let maxComponent = max(red, green, blue)
		let minComponent = min(red, green, blue)
		
		var hue: CGFloat = 0
		var saturation: CGFloat = 0
		let lightness = (maxComponent + minComponent) / 2.0
		
		let delta: CGFloat = maxComponent - minComponent
		
		if delta > 0 {
			if maxComponent == red {
				hue = (green - blue) / delta + (green < blue ? 6 : 0)
			} else if maxComponent == green {
				hue = (blue - red) / delta + 2
			} else {
				hue = (red - green) / delta + 4
			}
			hue /= 6
			saturation = delta / (1 - abs(2 * lightness - 1))
		}
		
		let h: Int = Int((hue * 360).rounded(.toNearestOrAwayFromZero))
		let s: Int = Int((saturation * 100).rounded(.toNearestOrAwayFromZero))
		let l: Int = Int((lightness * 100).rounded(.toNearestOrAwayFromZero))
		return "hsl(\(h)°, \(s)%, \(l)%)"
	}
	
	var nsColor: String {
		let nsRed: CGFloat = (.init(red) * 1.0) / 255.0
		let nsGreen: CGFloat = (.init(green) * 1.0) / 255.0
		let nsBlue: CGFloat = (.init(blue) * 1.0) / 255.0
		let nsAlpha: CGFloat = (.init(alpha) * 1.0) / 0xFF
		return "NSColor(red: \(nsRed), green: \(nsGreen), blue: \(nsBlue), alpha: \(nsAlpha))"
		//"NSColor(red: \(color.alphaComponent), green: \(color.greenComponent), blue: \(color.blueComponent), alpha: \(color.alphaComponent))"
	}
	
	func cacheIcon(fm: FileManager = .default) throws -> URL {
		let url: URL = URL(filePath: "\(cache)/\(hex).png")
		if !fm.fileExists(atPath: cache) {
			try fm.createDirectory(atPath: cache, withIntermediateDirectories: true)
		}
		if let png: Data = color.icon() {
			try png.write(to: url)
		}
		return url
	}
	
}

extension NSColor {
	
	func icon() -> Data? {
		var rect: NSRect = NSRect(origin: .zero, size: NSSize(width: 256, height: 256))
		let nsImage: NSImage = .init(size: rect.size, flipped: false) { rect in
			guard
				let context: CGContext = NSGraphicsContext.current?.cgContext
			else {
				return false
			}
			context.saveGState()
			context.setFillColor(self.cgColor)
			context.fill(rect)
			context.restoreGState()
			return true
		}
		guard let cgImage: CGImage = nsImage.cgImage(
			forProposedRect: &rect,
			context: NSGraphicsContext.current,
			hints: nil
		) else {
			return nil
		}
		
		/// Rounded Image PNG Data
		if let context = CGContext(
			data: nil,
			width: Int(rect.size.width),
			height: Int(rect.size.height),
			bitsPerComponent: 8,
			bytesPerRow: 4 * Int(rect.size.width),
			space: CGColorSpaceCreateDeviceRGB(),
			bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
		) {
			let radius: CGFloat = 35.0
			context.beginPath()
			context.addPath(
				CGPath(roundedRect: rect,
					   cornerWidth: radius,
					   cornerHeight: radius,
					   transform: nil))
			context.closePath()
			context.clip()
			context.draw(cgImage, in: rect)
		
			if let roundedCGImage: CGImage = context.makeImage(),
			   let imageRep = NSBitmapImageRep(
				data: NSImage(cgImage: roundedCGImage, size: rect.size).tiffRepresentation!
			   ),
			   let pngData: Data = imageRep.representation(
				using: NSBitmapImageRep.FileType.png,
				properties: [:])
			{
				return pngData
			}
		}
		
		return nil
	}
}


let colorSampler = NSColorSampler()
colorSampler.show { selectedColor in
	guard let color: NSColor = selectedColor else {
		print("No color selected", terminator: "")
		exit(1)
	}

	let c: Color = .init(nsColor: color)
	do {
		let icon: URL = try c.cacheIcon()
		var items: String = """
{
	"items": [
		{
			"title": "#\(c.hex)",
			"subtitle": "HEX",
			"arg": "#\(c.hex)",
			"icon": {
				"path": "\(icon.path)"
			}
		},
		{
			"title": "\(c.rgb)",
			"subtitle": "RGB",
			"arg": "\(c.rgb)",
			"icon": {
				"path": "\(icon.path)"
			}
		},
"""
		
		if showHSL {
			items += """
   {
   "title": "\(c.hsl)",
   "subtitle": "HSL",
   "arg": "\(c.hsl)",
   "icon": { "path": "\(icon.path)" }
   },
   """
		}
		
		if showNSColor {
			items += """
  {
	  "title": "\(c.nsColor)",
	  "subtitle": "NSColor",
	  "arg": "\(c.nsColor)",
	  "icon": {
		  "path": "\(icon.path)"
	  }
  },
"""
		}
		
		if showRGBa {
			items += """
  {
	  "title": "\(c.rgba)",
	  "subtitle": "RGBa",
	  "arg": "\(c.rgba)",
	  "icon": {
		  "path": "\(icon.path)"
	  }
  },
"""
		}
		
		items += "]}"
		print(items, terminator: "")
		exit(EXIT_SUCCESS)
		
	} catch let error as NSError {
		print(error.debugDescription, terminator: "")
		exit(EXIT_FAILURE)
	}
}



RunLoop.main.run()
