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
        
        let storyboard = UIStoryboard(name: AppConstants.Storyboard.signInUp, bundle: nil)
        let pin = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.validatePin)
        
        guard let viewController = viewController else {
            if let window = UIApplication.shared.delegate?.window as? UIWindow {
                window.rootViewController = pin
                window.makeKeyAndVisible()
            }
            
            return
        }
        
        viewController.present(pin, animated: true, completion: nil)
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

