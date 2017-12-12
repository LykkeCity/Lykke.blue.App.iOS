//
//  DefaultPlistParser.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/7/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation

public class DefaultPlistParser: PlistParser {
    public class func parseDict(filePath: String) -> [String: Any]? {
        if let path = Bundle.main.path(forResource: filePath, ofType: "plist"),
            let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            return dict
        }
        return nil
    }
    
    public class func parseArray(filePath: String) -> [[String: Any]]? {
        if let path = Bundle.main.path(forResource: filePath, ofType: "plist"),
            let array = NSArray(contentsOfFile: path) as? [[String: Any]] {
            return array
        }
        return nil
    }
}
