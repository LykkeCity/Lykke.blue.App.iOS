//
//  UINaviagtionBar+Extensions.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 21.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    func setTransparent() {
        setBackgroundImage(UIImage(), for: .default)
        shadowImage = UIImage()
        isTranslucent = true
        backgroundColor = .clear
    }
    
    func setOpaque() {
        setBackgroundImage(nil, for: .default)
        shadowImage = nil
    }
}
