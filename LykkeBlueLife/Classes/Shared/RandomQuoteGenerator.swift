//
//  RandomQuoteGenerator.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/7/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation

class RandomQuoteGenerator {
    typealias Quote = (author: String, quote: String)
    
    class func generate() -> (author: String, quote: String)? {
        guard let quotes = DefaultPlistParser.parseDict(filePath: AppConstants.Plist.quotes) else { return nil }
        
        let randomIndex = Int(arc4random_uniform(UInt32(quotes.count)))
        
        let quote = Array(quotes.keys)[randomIndex]
    
        guard let author = Array(quotes.values)[randomIndex] as? String else { return nil }
        
        let formattedAuthor = author != "" ? "- \(author)" : ""
        
        return Quote(formattedAuthor, quote)
    }
}
