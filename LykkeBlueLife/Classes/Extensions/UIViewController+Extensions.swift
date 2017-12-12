//
//  UIViewController+Extensions.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 7/27/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import UIKit
import WalletCore

extension UIViewController {
    @IBAction func swipeToNavigateBack(_ sender: UISwipeGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    func addDoneButton(_ textField: UITextField, selector: Selector)
    {
        let doneButton = UIButton()
        doneButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 45.0)
        doneButton.setTitle(Localize("buy.newDesign.done"), for: .normal)
        doneButton.backgroundColor = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        doneButton.titleLabel?.textColor = UIColor.white
        doneButton.addTarget(self, action: selector, for: .touchUpInside)
        
        textField.inputAccessoryView = doneButton
    }
    
    func show(error dictionary: [AnyHashable : Any]) {
        let errorMessage = dictionary[AnyHashable("Message")] as? String ?? Localize("errors.server.problems")
        show(errorMessage: errorMessage)
    }
    
    func show(errorMessage: String?) {
        let alertController = UIAlertController(title: Localize("utils.error"), message: errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    func pageControlSetTransparent() {
        for view in view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    func pageControlSetOpaque() {
        for view in view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl {
                view.backgroundColor = UIColor.white
            }
        }
    }
}


