//
//  PinPresenter.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 10/4/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit

class PinPresenter: Presenter {
    class func present(from viewController: UIViewController?,
                       viewControllerToPresent: UIViewController? = nil) {
        if UIApplication.topViewController() is ValidatePinViewController { return }
        
        
        var toPresent: UIViewController! = viewControllerToPresent
        
        if toPresent == nil {
            toPresent = ValidatePinViewController.pinPadViewController()
        }
        
        guard let viewController = viewController else {
            if let window = UIApplication.shared.delegate?.window as? UIWindow {
                window.rootViewController = toPresent
                window.makeKeyAndVisible()
            }
            
            return
        }
        
        viewController.present(toPresent, animated: true, completion: nil)
    }
    
    
    /// TODO: please refactor this
    ///
    /// - Parameters:
    ///   - viewControllerToDismiss: <#viewControllerToDismiss description#>
    ///   - animated: <#animated description#>
    ///   - completion: <#completion description#>
    class func dismiss(_ viewControllerToDismiss: UIViewController,
                       animated: Bool,
                       completion: (() -> Void)? = nil) {
        
        guard
            let window = UIApplication.shared.delegate?.window as? UIWindow,
            window.rootViewController == viewControllerToDismiss
        else {
            viewControllerToDismiss.dismiss(animated: animated, completion: completion)
            return
        }
        
        AppCoordinator.shared.showHome(fromViewController: nil)
    }
}

