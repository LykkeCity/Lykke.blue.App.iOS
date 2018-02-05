//
//  ViewControllerUXProtocol.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 2.02.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit

protocol ViewControllerUXProtocol {
    func setupTitle(_ title: String)
}

extension UIViewController: ViewControllerUXProtocol {
    func setupTitle(_ title: String) {
        
    }
}

extension UINavigationController {
    override func setupTitle(_ title: String) {
        if let vc = topViewController {
            vc.setupTitle(title)
        }
    }
}
