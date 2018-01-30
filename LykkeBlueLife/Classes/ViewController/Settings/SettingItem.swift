//
//  SettingItem.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 2.12.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import WalletCore
import RxCocoa
import RxSwift
import RxDataSources
import TwitterKit

class SettingItem: IdentifiableType, Equatable {
    typealias Identity = String
    var identity: String
    var handler: SettingItemProtocol
    
    init(id: String, handler: SettingItemProtocol) {
        self.identity = id
        self.handler = handler
    }
    
    static func ==(lhs: SettingItem, rhs: SettingItem) -> Bool {
        return lhs.identity == rhs.identity
    }
}

protocol SettingItemProtocol {
    var label: Driver<String> { get }
    var value: Driver<String> { get }
    var nextArrowIsHidden: Bool { get }
    func onSelect()
}

class SettingsNameItem: SettingItemProtocol {
    var label: Driver<String> { return Driver.just("name") }
    var value: Driver<String>
    var nextArrowIsHidden: Bool { return true }
    
    init(personalData: Observable<ApiResult<LWPacketPersonalData>>) {

        value = personalData
            .filterSuccess()
            .map{ $0.data.fullName }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
    }
    
    func onSelect() {
        
    }
}

class SettingsEmailItem: SettingItemProtocol {
    
    var label: Driver<String> { return Driver.just("email") }
    var value: Driver<String>
    var nextArrowIsHidden: Bool { return true }
    
    init(personalData: Observable<ApiResult<LWPacketPersonalData>>) {
        
        value = personalData
            .filterSuccess()
            .map{ $0.data.email }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
    }
    
    func onSelect() {
        
    }
}

class SettingsPhoneItem: SettingItemProtocol {
    var label: Driver<String> { return Driver.just("phone") }
    var value: Driver<String>
    var nextArrowIsHidden: Bool { return true }
    
    init(personalData: Observable<ApiResult<LWPacketPersonalData>>) {
        
        value = personalData
            .filterSuccess()
            .map{ $0.data.phone }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
    }
    
    func onSelect() {
        
    }
}

class SettingsBaseCurrencyItem: SettingItemProtocol {
    var label: Driver<String> { return Driver.just("base currency") }
    var value: Driver<String>
    var nextArrowIsHidden: Bool { return true }
    
    init(authManager: LWRxAuthManager) {
        let baseAsset = authManager.baseAsset.request()
        
        value = baseAsset
            .filterSuccess()
            .map{ $0.displayName }
            .asDriver(onErrorJustReturn: "")
    }
    
    func onSelect() {
        
    }
}

class SettingsTwitterItem: SettingItemProtocol {
    var label: Driver<String>
    var value = Driver.just("")
    var nextArrowIsHidden: Bool { return false }
    let twitter: Twitter
    let error = PublishSubject<Error>()
    
    var disposeBag = DisposeBag()
    
    init(twitter: Twitter) {
        self.twitter = twitter
        
        label = twitter.rx.isLoggedIn
            .asDriver(onErrorJustReturn: false)
            .map{ $0 ? "disconnect twitter account" : "connect twitter account" }
    }
    
    func onSelect() {
        disposeBag = DisposeBag()
        
        guard twitter.sessionStore.hasLoggedInUsers() else {
            twitter.rx.login()
                .filterSuccess()
                .subscribe()
                .disposed(by: disposeBag)
            
            return
        }
        
        twitter.rx.logout()
            .subscribe()
            .disposed(by: disposeBag)
    }
}

class SettingsTermsOfUseItem: SettingItemProtocol {
    var label: Driver<String> { return Driver.just("terms of use") }
    var value = Driver.just("")
    var nextArrowIsHidden: Bool { return false }
    var url = PublishSubject<URL>()
    
    func onSelect() {
        url.onNext(URL(string: "https://www.lykke.com/terms_of_use")!)
    }
}

class SettingsSupportItem: SettingItemProtocol{
    var label: Driver<String> { return Driver.just("support") }
    var value = Driver.just("")
    var nextArrowIsHidden: Bool { return false }
    
    func onSelect() {
        let url = URL(string: "mailto:\(AppConstants.supportEmail)")
        UIApplication.shared.openURL(url!)
    }
}

class SettingsLogoutItem: SettingItemProtocol{
    var label: Driver<String> { return Driver.just("logout") }
    var value: Driver<String>
    var nextArrowIsHidden: Bool { return true }
    let twitter: Twitter
    
    let disposeBag = DisposeBag()
    
    init(personalData: Observable<ApiResult<LWPacketPersonalData>>, twitter: Twitter) {
        
        
        self.twitter = twitter
        value = personalData
            .filterSuccess()
            .map{ $0.data.email }
            .replaceNilWith("")
            .asDriver(onErrorJustReturn: "")
    }
    
    func onSelect() {
        if LWKeychainManager.instance().isAuthenticated {
            LWAuthManager.instance().requestLogout()
        }
        
        LWKeychainManager.instance().clear()
        LWPrivateKeyManager.shared().logoutUser()
        LWKYCDocumentsModel.shared().logout()
        LWEthereumTransactionsManager.shared().logout()
        LWMarginalWalletsDataManager.stop()
        
        UserDefaults.standard.set(nil, forKey: UserDefaultsKeys.footprintValue)
        UserDefaults.standard.set(nil, forKey: UserDefaultsKeys.netPositiveValue)
        
        twitter.rx.logout()
            .subscribe(onNext: { _ in
                AppCoordinator.shared.showQuote(fromViewController: nil)
            })
            .disposed(by: disposeBag)
    }
}

class SettingsBackupWalletItem: SettingItemProtocol {
    var label: Driver<String> { return Driver.just("backup private key") }
    var value = Driver.just("")
    var nextArrowIsHidden: Bool { return false }
    
    weak var presenter: UIViewController?
    
    init(presenter: UIViewController) {
        self.presenter = presenter
    }
    
    func onSelect() {
        presenter?.performSegue(withIdentifier: AppConstants.Segue.showBeginPrivateKeyBackup, sender: self)
    }
}
