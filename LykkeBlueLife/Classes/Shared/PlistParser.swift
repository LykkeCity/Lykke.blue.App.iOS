//
//  PlistParser.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/7/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation

public protocol PlistParser {
    static func parseDict(filePath: String) -> [String: Any]?
    
    static func parseArray(filePath: String) -> [[String: Any]]?
}
