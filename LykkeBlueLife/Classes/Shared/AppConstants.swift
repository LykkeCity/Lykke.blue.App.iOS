//
//  AppConstants.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 10/5/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation

public enum AppConstants {
    
    public static let partnerId = "Lykke.blue"
    public static let supportEmail = "support@lykke.blue"
    
    public enum Twitter {
        public static let hashTag =  "#lykkeblue"
    }
    
    public enum Segue {
        public static let showVerifyBackup = "showVerifyBackup"
        public static let showQuoteScreen = "showQuoteScreen"
        public static let showOnboardingVideoScreen = "showOnboardingVideoScreen"
        public static let showVerifyEmail = "showVerifyEmail"
        public static let showAddPhoneNumber = "showAddPhoneNumber"
        public static let showVerifyPhone = "showVerifyPhone"
        public static let showSetPassword = "showSetPassword"
        public static let showSetPin = "showSetPin"
        public static let showConfirmPin = "showConfirmPin"
        public static let showGeneratePrivateKey = "showGeneratePrivateKey"
        public static let showSignInPin = "showSignInPin"
        public static let showSignInSMSCode = "showSignInSMSCode"
        public static let showProfile = "showProfile"
        public static let showQuote = "showQuote"
        public static let showBeginPrivateKeyBackup = "showBeginPrivateKeyBackup"
        public static let showPrivateKeyWords = "showPrivateKeyWords"
    }
    
    public enum Storyboard {
        public static let main = "Main"
        public static let signInUp = "SignInUp"
        public static let onboarding = "Onboarding"
        public static let pledge = "Pledge"
        public static let signUpNav = "SignUpNav"
        public static let backupPrivateKey = "BackupPrivateKey"
    }
    
    public enum Screen {
        public static let quote = "Quote"
        public static let home = "Home"
        public static let signIn = "SignInUpNav"
        public static let validatePin = "ValidatePinCode"
        public static let manifesto = "Manifesto"
        public static let footprint = "Footprint"
        public static let twitter = "Twitter"
        public static let community = "Community"
        public static let profile = "Profile"
        public static let startPrivateKeyBackup = "BackupPrivateKeyContainer"
    }
    
    public enum Navigation {
        public static let profileTitle = "profile"
    }
    
    public enum ImageName {
        public static let backNav = "backNav"
        public static let communityGreenRing = "ringLargeGreen"
        public static let treeAssetIcon = "treeAssetGreen"
        public static let communityBackground = "communityBackground"
        public static let profileNoImageWhite = "profileNoImageWhite"
        public static let profileNoImage = "profileNoImage"
        public static let onboardingVideoBackgroundImage = "introVideoBg"
    }
    
    public enum Plist {
        public static let quotes = "quotes"
    }
}
