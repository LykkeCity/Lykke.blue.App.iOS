//
//  LWPrivateKeyManager+Extensions.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 1.02.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import Foundation
import WalletCore

extension LWPrivateKeyManager {
    
    func generatePrivateKeyWords() -> [String] {
        if let words = self.privateKeyWords() as? [String] {
            return words
        }
        
        if let encryptedKey = self.encryptedKeyLykke {
            self.decryptLykkePrivateKeyAndSave(encryptedKey)
            if let words = self.privateKeyWords() as? [String] {
                return words
            }
        }
        return LWPrivateKeyManager.generateSeedWords12() as! [String]
    }
}
