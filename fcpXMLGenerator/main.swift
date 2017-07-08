//
//  main.swift
//  fcpXMLGenerator
//
//  Created by Damiaan on 1/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

struct AtemCut: Codable {
	let timecode: UInt
	let source: Int
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		source = try container.decode(Int.self, forKey: .source)
		let timecodeComponents = try container.decode([UInt].self, forKey: .timecode)
		timecode = timecodeComponents[0]*60*60*25 + timecodeComponents[1]*60*25 + timecodeComponents[2]*25 + timecodeComponents[3]
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
	value: { try decoder.decode([AtemCut].self, from: dataContent) }
) else {
	exit(EXIT_FAILURE)
}

let angleIDs = ["","","",
                "ShGzMjlURAOQaKvvkViLsg",
                "X+PUoajRR7qt1+8WwCDFCg",
                "yjkHZdNmR2y8/NrEATFk9g",
                "UtLnlmx/RvC9aGr1RHl2PA",
                "d8nY6HTnT7OXjBvP1Rxy5w",
                "ryJYZISmT5CaFVA53AV1Kw",
]

let  root = XMLElement(name: "spine")
let audio = XMLElement(name: "mc-source")
audio.setAttributesWith([
	"angleID": "yvTXB1F9Q42RoWebKFzNdw",
	"srcEnable": "audio"
])

let sources = angleIDs.map { angleID -> XMLElement in
	let source = XMLElement(name: "mc-source")
	source.setAttributesWith([
		"angleID": angleID,
		"srcEnable": "video"
	])
	return source
}

if let firstCut = cuts.first {
	var previousCut = firstCut
	for cut in cuts.dropFirst() {
		let clip = XMLElement(name: "mc-clip")
		clip.setAttributesWith([
			"start": "\(previousCut.timecode-158084)/25s",
			"duration": "\(cut.timecode - previousCut.timecode)/25s",
			"offset": "\(previousCut.timecode - firstCut.timecode)/25s",
			"name": "Dag 2",
			"ref": "r2",
		])
		clip.addChild(sources[previousCut.source].copy() as! XMLElement)
		clip.addChild(audio.copy() as! XMLElement)
		root.addChild(clip)
		previousCut = cut
	}
}

print(root.xmlString)
