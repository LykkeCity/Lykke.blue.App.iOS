//
//  UserDefaults+Extensions.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 10/11/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation

extension UserDefaults {
    static func isFirstLaunch() -> Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasBeenLaunchedBefore)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasBeenLaunchedBefore)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
    
    static func isOnboardingFirstLaunch() -> Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasOnboaringBeenLaunchedBefore)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasOnboaringBeenLaunchedBefore)
            UserDefaults.standard.synchronize()
        }
        return isFirstLaunch
    }
}
