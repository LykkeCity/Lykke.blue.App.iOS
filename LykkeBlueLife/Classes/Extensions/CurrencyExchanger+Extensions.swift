//
//  CurrencyExchanger+Extensions.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 20.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import WalletCore
import RxSwift


extension CurrencyExchanger {
    convenience init() {
        self.init(refresh: Observable<Void>.interval(5.0))
    }
}
