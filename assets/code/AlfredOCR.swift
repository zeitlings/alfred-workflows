//
//  AlfredOCR.swift
//  Optical Character Recognition Workflow
//
//  Created by Patrick Sy on 02/03/2023.
//

import AppKit
import Vision

let PATH: String = "/tmp/snap.png"

struct AlfredOCR {
	static let environment: [String:String] = ProcessInfo.processInfo.environment
	static let fileManager: FileManager = .default
	static var snap: URL!
	
	static func run() {
		fileManager.validate()
		recognizeText(in: snap)
	}
}

extension AlfredOCR {
		
	static func recognizeText(
		in imageURL: URL,
		revision: Int = revision,
		recognizeLanguage: Bool = true,
		languages: [String] = languages,
		recognitionLevel: VNRequestTextRecognitionLevel = .accurate,
		handler: @escaping (VNRequest, Error?) -> () = ocrHandler
	) {
		let nsImage: NSImage = .init(byReferencing: imageURL)
		guard
			let image: CGImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
		else {
			print("OCR Failure: CGImage")
			Darwin.exit(EXIT_FAILURE)
		}
		let requestHandler = VNImageRequestHandler(cgImage: image)
		let request = VNRecognizeTextRequest(completionHandler: handler)
		request.recognitionLanguages = languages
		request.usesLanguageCorrection = recognizeLanguage
		request.recognitionLevel = recognitionLevel
		request.revision = revision
		do {
			try requestHandler.perform([request])
		} catch {
			print("OCR Failure: Unable to perform the request with error: \(error.localizedDescription)")
			Darwin.exit(EXIT_FAILURE)
		}
	}
	
	static private func ocrHandler(request: VNRequest, error: Error?) {
		guard let observations = request.results as? [VNRecognizedTextObservation] else {
			return
		}
		let pasteBoard: NSPasteboard = .general
		let recognized: [String] = observations.compactMap({ $0.topCandidates(1).first?.string })
		let merged: String = recognized.joined(separator: "\n")
		try? fileManager.removeItem(atPath: PATH)
		pasteBoard.clearContents()
		pasteBoard.setString(merged, forType: .string)
		print(merged)
		Darwin.exit(EXIT_SUCCESS)
	}
	
	static let languages: [String] = {
		if let raw: String = environment["languages"] {
			let components: [String] = raw.split(separator: ",")
				.map({ $0.trimmingCharacters(in: .whitespaces) })
			guard !components.isEmpty else { return [] }
			return components
		}
		return []
	}()

	static let revision: Int = Int(environment["revision"] ?? "") ?? 3
}

extension FileManager {
	@discardableResult
	func validate() -> Never? {
		guard fileExists(atPath: PATH) else {
			print("OCR Failure: Nothing to recognize")
			Darwin.exit(EXIT_FAILURE)
		}
		AlfredOCR.snap = URL(filePath: PATH)
		return nil
	}
}

AlfredOCR.run()
