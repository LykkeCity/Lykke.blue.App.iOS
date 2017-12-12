//
//  KeyboardView.swift
//  RxLoginExample
//
//  Created by Mac X on 8/24/17.
//  Copyright © 2017 Mac X. All rights reserved.
//

import Foundation
import UIKit

class KeyboardView : UIScrollView {
    
    var keyboardUp = Bool()
    var originalConstraint = CGFloat()
    var keyboardFrameBeginRect = CGRect()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func onKeyboardWillShow(_ notification: Notification) {
        if keyboardUp == false {
            keyboardUp = true
            let keyboardInfo = notification.userInfo
            let keyboardFrameBegin = keyboardInfo?["UIKeyboardFrameBeginUserInfoKey"] as? CGRect
            keyboardFrameBeginRect = keyboardFrameBegin!
            var heightConstraint = NSLayoutConstraint()
            let contentView = self.subviews[0]
            for constraint in contentView.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.height {
                    heightConstraint = constraint
                    break
                }
            }
            originalConstraint = heightConstraint.constant
            heightConstraint.constant = originalConstraint + keyboardFrameBeginRect.size.height
            self.perform(#selector(scrollToCurrentControll), with: self.subviews[0], afterDelay: 0.1)
            
        }
    }
    
    func onKeyboardWillHide(_ notification: Notification){
        if keyboardUp {
            keyboardUp = false
            var heightConstraint = NSLayoutConstraint()
            let contentView = self.subviews[0]
            for constraint in contentView.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.height {
                    heightConstraint = constraint
                    break
                }
            }
            heightConstraint.constant = originalConstraint
        }
    }
    
    func scrollToCurrentControll(_ object: AnyObject) {
        for v in object.subviews {
            if v is UITextField || v is UITextView || v is SkyFloatingLabelTextField {
                if v.isFirstResponder {
                    let keyboardHeight = keyboardFrameBeginRect.size.height
                    let origin = v.frame.origin
                    let point = v.convert(origin, to: self.subviews[0])
                    let y = point.y - origin.y + keyboardHeight + 5
                    self.scrollRectToVisible(CGRect(x: 0, y: y, width: self.frame.size.width, height: v.frame.size.height), animated: true)
                    return
                    
                }
            }
            scrollToCurrentControll(v)
        }
    }
}
