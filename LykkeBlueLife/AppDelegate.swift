//
//  AppDelegate.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/16/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import TwitterKit
import Firebase
import WalletCore
import NVActivityIndicatorView
import Crashlytics
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var tempUsername : String = ""
    var tempPassword : String = ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Twitter.sharedInstance().start(withConsumerKey: AppConstants.Twitter.consumerKey,
                                       consumerSecret: AppConstants.Twitter.consumerSecret)
        
        FirebaseApp.configure()
        
        if UserDefaults.isFirstLaunch() {
            LWKeychainManager.instance().clear()
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if LWKeychainManager.instance().isAuthenticated {
            AppCoordinator.shared.presentPin(from: nil)
        } else {
            AppCoordinator.shared.presentOnboarding(from: nil)
        }

        #if ENV_TEST
            WalletCoreConfig.configurePartnerId(AppConstants.partnerId, testingServer: .test)
            Fabric.sharedSDK().debug = true
        #elseif ENV_DEV
            WalletCoreConfig.configurePartnerId(AppConstants.partnerId, testingServer: .develop)
            Fabric.sharedSDK().debug = true
        #else
            WalletCoreConfig.configure(AppConstants.partnerId)
        #endif
        
        NVActivityIndicatorView.DEFAULT_COLOR = #colorLiteral(red: 0.5499413013, green: 0.8448511958, blue: 0.9883074164, alpha: 1)
        NVActivityIndicatorView.DEFAULT_TYPE = .ballScale
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if let dynamicLink = DynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url) {
            handleIncomingDynamicLink(dynamicLink)
            return true
        }
        return Twitter.sharedInstance().application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            let linkHandled = DynamicLinks.dynamicLinks()?.handleUniversalLink(incomingURL, completion: {
                [weak self] (dynamicLink, error) in
                if let dynamicLink = dynamicLink, let _ = dynamicLink.url {
                    self?.handleIncomingDynamicLink(dynamicLink)
                }
            }) ?? false
            
            return linkHandled
        }
        
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if LWKeychainManager.instance().isAuthenticated {
            AppCoordinator.shared.presentPin(from: UIApplication.topViewController())
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url?.absoluteString else { return }
        
        let referralLinkHelper = ReferralLinkHelper()
        
        referralLinkHelper.isInvitationLink(url, completion: { invitation in
            if invitation {
                let refId = referralLinkHelper.parseReferralId(forUrl: url)
                UserDefaults.standard.set(refId, forKey: UserDefaultsKeys.referralLinkId)
                UserDefaults.standard.synchronize()
            }
        })
    }
}

