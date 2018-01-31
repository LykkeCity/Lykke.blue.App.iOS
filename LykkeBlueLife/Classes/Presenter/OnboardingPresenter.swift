//
//  OnboardingPresenter.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/3/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit

class OnboardingPresenter: Presenter {
    class func present(from viewController: UIViewController?,
                       viewControllerToPresent: UIViewController? = nil) {
        let storyboard = UIStoryboard(name: AppConstants.Storyboard.onboarding, bundle: nil)
        let manifesto = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.manifesto)
        
        guard let viewController = viewController else {
            if let window = UIApplication.shared.delegate?.window as? UIWindow {
                window.rootViewController = manifesto
                window.makeKeyAndVisible()
            }
            
            return
        }
        
        viewController.present(manifesto, animated: true, completion: nil)
    }
    
    class func dismiss(_ viewControllerToDismiss: UIViewController,
                       animated: Bool,
                       completion: (() -> Void)? = nil) {
        viewControllerToDismiss.dismiss(animated: animated, completion: completion)
    }
}
