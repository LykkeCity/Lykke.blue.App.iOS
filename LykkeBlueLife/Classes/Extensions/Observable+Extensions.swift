//
//  Observable+Extensions.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 20.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import WalletCore

extension ObservableType where Self.E == Void {
    
    static func interval(_ period: RxTimeInterval) -> Observable<Void> {
        return Observable<Int>
            .interval(period, scheduler: MainScheduler.instance)
            .map{_ in Void()}
            .filter{
                return UIApplication.shared.applicationState.isActive && LWKeychainManager.instance().isAuthenticated
            }
            .startWith(Void())
            .throttle(2.0, scheduler: MainScheduler.instance)
            .shareReplay(1)
    }
}

extension UIApplicationState {
    var isActive: Bool {
        if case .active = UIApplication.shared.applicationState {
            return true
        }
        
        return false
    }
}
