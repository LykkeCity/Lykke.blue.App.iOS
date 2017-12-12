//
//  SettingsViewController+Sections.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 8.12.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import WalletCore
import RxCocoa
import RxSwift
import TwitterKit
import RxDataSources
import SafariServices

extension SettingsViewController {
    var sections: [SettingsSection] {
        let personalData = LWRxAuthManager.instance.settings.request()
        
        return [
            SettingsSection(header: "private information", items: [
                SettingItem(id: "email", handler: SettingsEmailItem(personalData: personalData)),
                SettingItem(id: "phone", handler: SettingsPhoneItem(personalData: personalData))
            ]),
            SettingsSection(header: "app settings", items: [
                SettingItem(id: "baseCurrency", handler: SettingsBaseCurrencyItem(authManager: LWRxAuthManager.instance)),
                twitterItem,
            ]),
            SettingsSection(header: "general", items: [
                touItem,
                SettingItem(id: "support", handler: SettingsSupportItem()),
            ]),
            SettingsSection(header: "", items: [
                SettingItem(id: "logout", handler: SettingsLogoutItem(personalData: personalData, twitter: Twitter.sharedInstance()))
            ])
        ]
    }
}

fileprivate extension SettingsViewController {
    var twitterItem: SettingItem {
        let handler = SettingsTwitterItem(twitter: Twitter.sharedInstance())
        let twitterItem = SettingItem(id: "twitter", handler: handler)
        
        handler.error.asObservable()
            .subscribe(onNext: { [weak self] error in
                let alert = UIAlertController(title: "Twitter error.", message: error.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                }
                
                alert.addAction(okAction)
                
                self?.present(alert, animated: false, completion: nil)
            })
            .disposed(by: disposeBag)
        
        return twitterItem
    }
    
    var touItem: SettingItem {
        let touHandler = SettingsTermsOfUseItem()
        let tou = SettingItem(id: "tou", handler: touHandler)
        
        touHandler.url.asObservable()
            .subscribe(onNext: { [weak self] url in
                self?.present(SFSafariViewController(url: url), animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        return tou
    }
}
