//
//  AppTheme.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/14/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit

struct AppTheme {
    static var inviteButtonBackgroundColor: UIColor {
        return UIColor(red: 14.0/255, green: 155.0/255, blue: 249.0/255, alpha: 1.0)
    }
    
    static var inviteButtonFont: UIFont? {
        return UIFont(name: "AmericanTypewriter", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
    }
    
    static var labelDarkColor: UIColor {
        return UIColor(red: 1.0/255, green: 50.0/255, blue: 67.0/255, alpha: 1.0)
    }
    
    static var navigationTitleFont: UIFont {
        return UIFont(name: "AmericanTypewriter", size: 16.0) ?? UIFont.systemFont(ofSize: 16.0)
    }
    
    static var pageControlSelectedColor: UIColor {
        return UIColor(red: 124.0/255, green: 206.0/255, blue: 251.0/255, alpha: 1.0)
    }
    
    static var appBlue: UIColor {
        return UIColor(red: 124.0/255, green: 206.0/255, blue: 251.0/255, alpha: 1.0)
    }
    
    static var profileBackgroundColor: UIColor {
        return UIColor(red: 242.0/255, green: 245.0/255, blue: 245.0/255, alpha: 1.0)
    }
    
    static var profileProgressCircleEmptyColor: UIColor {
        return UIColor(red: 1.0/255, green: 50.0/255, blue: 67.0/255, alpha: 0.1)
    }
    
    static var profileProgressCircleFillColor: UIColor {
        return UIColor(red: 14.0/255, green: 150.0/255, blue: 249.0/255, alpha: 1.0)
    }

}
