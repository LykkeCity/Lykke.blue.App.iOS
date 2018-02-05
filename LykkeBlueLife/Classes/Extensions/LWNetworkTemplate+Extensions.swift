//
//  LWNetworkTemplate+Extensions.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 1.02.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import Foundation
import WalletCore

extension LWNetworkTemplate: LWAuthManagerDelegate {
    
    func showReleaseError(_ error: NSError, request: NSURLRequest) {
        // TODO: Implement
    }
    
    func showBackupView(_ isOptional: Bool, message: String) {
        DispatchQueue.main.async {
            guard let vc = UIApplication.topViewController() else {
                return
            }
            
            let storyboard = UIStoryboard(name: AppConstants.Storyboard.backupPrivateKey, bundle: nil)
            let backupVC = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.startPrivateKeyBackup)
            backupVC.setupTitle(message)
            vc.present(backupVC, animated: true)
        }
    }
    
    func showKycView() {
        // TODO: Implement
    }
    
    public func authManager(_ manager: LWAuthManager!, didGetKYCStatus status: String!, personalData: LWPersonalDataModel!) {
        // TODO: Implement
    }
}
