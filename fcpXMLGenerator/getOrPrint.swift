//
//  getOrPrint.swift
//  fcpXMLGenerator
//
//  Created by Damiaan on 1/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

func getOrPrint<T>(errorMessage: String, value: () throws -> T) -> T? {
	do {
		return try value()
	} catch {
		print(errorMessage)
		print(error)
		return nil
	}
}
