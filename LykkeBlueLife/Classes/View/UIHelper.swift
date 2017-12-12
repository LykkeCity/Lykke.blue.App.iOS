//
//  UIHelper.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/22/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore

public class UIHelper: NSObject {
    static func showErrorMessage(messageDict: [AnyHashable : Any] , forViewController: UIViewController)
    {
        for (field, value) in messageDict where field == AnyHashable("Message") {
            let message = value
            print(message)
            let alertController = UIAlertController(title: Localize("utils.error"), message: message as? String, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            
            alertController.addAction(okAction)
            forViewController.present(alertController, animated: true, completion: nil)
            break
        }
        //if not found
        let alertController = UIAlertController(title: Localize("utils.error"), message: Localize("errors.server.problems"), preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        forViewController.present(alertController, animated: true, completion: nil)

        
    }
}
