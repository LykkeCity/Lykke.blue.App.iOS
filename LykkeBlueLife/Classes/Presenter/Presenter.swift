//
//  Presenter.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 10/4/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit

public protocol Presenter {
    static func present(from viewController: UIViewController?,
                        viewControllerToPresent: UIViewController?)
    
    static func dismiss(_ viewControllerToDismiss: UIViewController,
                        animated: Bool,
                        completion: (() -> Void)?)
}
