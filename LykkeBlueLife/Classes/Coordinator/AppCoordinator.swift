//
//  AppCoordinator.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/20/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import WalletCore
import RxSwift

public class AppCoordinator {
    
    static let shared = AppCoordinator()
    
    private init() {
        subscribeForUnauthorized()
    }
    
    public func presentOnboarding(from viewController: UIViewController?) {
        OnboardingPresenter.present(from: viewController)
    }
    
    public func presentPin(from viewController: UIViewController?) {
        PinPresenter.present(from: viewController)
    }
    
    public func presentLogin(fromViewController viewController: UIViewController?) {
        let storyboard = UIStoryboard(name: AppConstants.Storyboard.signInUp, bundle: nil)
        let signUp = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.signIn)
        
        viewController?.present(signUp, animated: false, completion: nil)
    }
    
    
    /// Set thehome screen as root view controller to the window, if the window does not exists present it from given view controller
    ///
    /// - Parameter viewController: a view controller that will present home screen
    public func showHome(fromViewController viewController: UIViewController?) {

        let storyboard = UIStoryboard(name: AppConstants.Storyboard.main, bundle: nil)
        let home = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.home)
        
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.rootViewController = home
            window.makeKeyAndVisible()
            return
        }
        
        viewController?.present(home, animated: true, completion: nil)
    }
    
    
    /// TODO: Refactor this method
    ///
    /// - Parameter viewController: <#viewController description#>
    public func showQuote(fromViewController viewController: UIViewController?) {
        
        let storyboard = UIStoryboard(name: AppConstants.Storyboard.onboarding, bundle: nil)
        let home = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.quote)
        
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            window.rootViewController = home
            window.makeKeyAndVisible()
            return
        }
        
        viewController?.present(home, animated: true, completion: nil)
    }
    
    deinit {
        unsubscribeForUnauthorized()
    }
}

// MARK: Private

fileprivate extension AppCoordinator {
    func subscribeForUnauthorized() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUnauthorized(_:)),
            name: NSNotification.Name(rawValue: kNotificationGDXNetAdapterDidFailRequest),
            object: nil
        )
    }
    
    func unsubscribeForUnauthorized() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleUnauthorized(_ notification: NSNotification) {
        guard let ctx = notification.userInfo?[kNotificationKeyGDXNetContext] as? GDXRESTContext else { return }
        guard LWAuthManager.isAuthneticationFailed(ctx.task?.response)  else { return }
        
        LWKeychainManagerHelper.reset()
        presentLogin(fromViewController: UIApplication.topViewController())
    }
}
