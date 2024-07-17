#!/usr/bin/swift
//
//  QResolve.swift
//  Resolve and open URLs from QR codes
//
//  Created by Patrick Sy on 08/05/2023.
//

import CoreImage

let qrPath: String = "/tmp/qrsnap.png"

struct QResolver {
	static let fileManager: FileManager = .default
	static func run() {
		if let snap: CIImage = fileManager.getSnap(),
		   let detector: CIDetector = .quickResponse()
		{
			fileManager.removeSnap()
			for feature in detector.features(in: snap) where feature is CIQRCodeFeature {
				guard let feature = feature as? CIQRCodeFeature,
					  let landingPage: String = feature.messageString
				else {
					preconditionFailure()
				}
				print(landingPage, terminator: "")
				exit(0)
			}
		}
		fileManager.removeSnap()
		print("Failure: No valid QR code detected")
	}
}

extension FileManager {
	@discardableResult
	func getSnap() -> CIImage? {
		guard fileExists(atPath: qrPath) else {
			if let received: String = ProcessInfo.processInfo.environment["qr"] {
				return CIImage(contentsOf: URL(filePath: received))
			}
			print("Failure: Nothing to recognize")
			exit(1)
		}
		return CIImage(contentsOf: URL(filePath: qrPath))
	}
	
	func removeSnap() {
		try? removeItem(atPath: qrPath)
	}
}

extension CIDetector {
	static func quickResponse() -> CIDetector? {
		.init(ofType: CIDetectorTypeQRCode, context: nil, options: nil)
	}
}

QResolver.run()
