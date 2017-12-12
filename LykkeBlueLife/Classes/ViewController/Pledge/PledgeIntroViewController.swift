//
//  PledgeIntroViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/27/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import WalletCore

class PledgeIntroViewController: UIViewController {
    @IBAction func close(_ sender: Any) {
        if LWKeychainManager.instance().isAuthenticated {
            dismiss(animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: AppConstants.Segue.showQuote, sender: nil)
        }
    }
    
}
