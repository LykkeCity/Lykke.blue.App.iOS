//
//  UIViewController+Rx.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 21.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import WalletCore
import RxCocoa
import RxSwift
import NVActivityIndicatorView

extension Reactive where Base: UIViewController {
    
    var indicatorView: NVActivityIndicatorView? {
        
        if let addedIndicatorView = (base.view.subviews.first{ $0 is NVActivityIndicatorView }) as? NVActivityIndicatorView {
            return addedIndicatorView
        }
        
        guard let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first else {
            return nil
        }
        
        let indicatorView = NVActivityIndicatorView(frame: window.frame)
        
        base.view.addSubview(indicatorView)
        
        return indicatorView
    }

    
    var loading: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { [indicatorView] vc, value in
            
            guard value else {
                indicatorView?.stopAnimating()
                return
            }
            
            if let inputForm = vc as? UIViewController & InputForm {
                inputForm.endEditing()
            }
            
            indicatorView?.startAnimating()
        }
    }
    
    func hideLoading() {
        indicatorView?.stopAnimating()
    }
    
    var error: UIBindingObserver<Base, [AnyHashable: Any]> {
        return UIBindingObserver(UIElement: self.base) { vc, value in
            vc.show(error: value)
        }
    }
}
