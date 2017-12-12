//
//  LWKeychainManagerHelper.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/21/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import WalletCore

public class LWKeychainManagerHelper {
    public class func reset() {
        if LWKeychainManager.instance().isAuthenticated {
            LWAuthManager.instance().requestLogout()
        }
        LWKeychainManager.instance().clear();
        LWPrivateKeyManager.shared().logoutUser()
        LWKYCDocumentsModel.shared().logout()
        LWImageDownloader.shared().logout()
        LWEthereumTransactionsManager.shared().logout()
        LWMarginalWalletsDataManager.stop()
    }
}
