//
//  UIImageView+Rx.swift
//  LykkeWallet
//
//  Created by Georgi Stanev on 8/1/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import AlamofireImage

extension Reactive where Base: UIImageView {
    /// Bindable sink for `enabled` property.
    var isHighlighted: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { imageView, value in
            imageView.isHighlighted = value
        }
    }
    
    /// - parameter transitionType: Optional transition type while setting the image (kCATransitionFade, kCATransitionMoveIn, ...)
    var afImage: UIBindingObserver<Base, URL> {
        return UIBindingObserver(UIElement: base) { imageView, url in
            imageView.af_setImage(withURL: url)
        }
    }
}
