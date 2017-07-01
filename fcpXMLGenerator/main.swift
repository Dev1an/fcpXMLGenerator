//
//  main.swift
//  fcpXMLGenerator
//
//  Created by Damiaan on 1/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

struct AtemCut: Codable {
	let timecode: [UInt]
	let source: UInt
}

struct CompressedAtemCut {
	let timecode: UInt
	let source: UInt
	
	init(_ atemCut: AtemCut) {
		source = atemCut.source
		timecode = atemCut.timecode[0]*60*60*25 + atemCut.timecode[1]*60*25 + atemCut.timecode[2]*25 + atemCut.timecode[3]
	}
}

guard CommandLine.arguments.count >= 2 else {
	print("Usage: fcpXMLGenerator <path to JSON file>")
	print("change <path to JSON file> in the above command with the path to your JSON file")
	exit(EXIT_FAILURE)
}
let fileURL = URL(fileURLWithPath: CommandLine.arguments[1])

guard let dataContent = getOrPrint(
	errorMessage: "Unable to read text content of file at: \(fileURL)",
	value: { try Data(contentsOf: fileURL) }
) else {
	exit(EXIT_FAILURE)
}

let decoder = JSONDecoder()

guard let cuts = getOrPrint(
	errorMessage: "Unable to decode JSON",
	value: { try decoder.decode([AtemCut].self, from: dataContent).map {CompressedAtemCut($0)}.sorted {$0.timecode < $1.timecode} }
) else {
	exit(EXIT_FAILURE)
}

//print(cuts)

let root = XMLElement(name: "spine")

if let firstCut = cuts.first {
	var previousCut = firstCut
	for cut in cuts.dropFirst() {
		let clip = XMLElement(name: "asset-clip")
		clip.setAttributesWith([
			"start": "\(previousCut.timecode+1)/25s",
			"duration": "\(cut.timecode - previousCut.timecode)/25s",
			"offset": "\(previousCut.timecode - firstCut.timecode)/25s",
			"name": "Blackmagic HyperDeck Studio Mini[0004]",
			"ref": "r2",
			"audioRole": "dialogue",
			"tcFormat": "NDF"
		])
		root.addChild(clip)
		previousCut = cut
	}
}

print(root.xmlString)
