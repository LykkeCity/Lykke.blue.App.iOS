//
//  ManifestoViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/6/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit

class ManifestoViewController: UIViewController {
    
    @IBAction func next(_ sender: Any) {
        if UserDefaults.isOnboardingFirstLaunch() {
            performSegue(withIdentifier: AppConstants.Segue.showOnboardingVideoScreen, sender: self)
        } else {
            performSegue(withIdentifier: AppConstants.Segue.showQuoteScreen, sender: self)
        }
    }
}
