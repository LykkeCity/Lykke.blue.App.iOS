//
//  Driver+Extensions.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 26.01.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension Driver where E == URL {
    
    /**
     Creates new subscription for image URL, downloads it and updates the ImageView with chosen tint.
     Make sure the fetched image is suitable for rendering as template. (should be all white)
     
     - returns: Disposable object that can be used to unsubscribe the observer from the variable.
     - parameter imageView: Target ImageView for updates.
     - parameter withTint: The tint of the new image, leave nil to use the already set value in imageView.
     - parameter onCompleted: Action to invoke upon graceful termination of the observable sequence.
     gracefully completed, errored, or if the generation is canceled by disposing subscription)
     - parameter onDisposed: Action to invoke upon any type of termination of sequence (if the sequence has
     gracefully completed, errored, or if the generation is canceled by disposing subscription)
     - returns: Subscription object used to unsubscribe from the observable sequence.
     */
    func drive(_ imageView: UIImageView,
               withTint: UIColor? = nil,
               onCompleted: (() -> Void)? = nil,
               onDisposed: (() -> Void)? = nil) -> Disposable {
        let tint = withTint ?? imageView.tintColor
        weak var imageView = imageView
        let disposable = self.asObservable().subscribe(onNext: { (url) in
                imageView?.af_setImage(withURL: url,
                                  placeholderImage: nil,
                                  filter: nil,
                                  progress: nil,
                                  progressQueue: DispatchQueue.global(qos: .default),
                                  imageTransition: UIImageView.ImageTransition.crossDissolve(0.2),
                                  runImageTransitionIfCached: true,
                                  completion: { [weak imageView] (dataResponse) in
                                    let img = dataResponse.value
                                    imageView?.tintColor = tint
                                    imageView?.image = img?.withRenderingMode(.alwaysTemplate)
                            })
            
        }, onError: nil, onCompleted: onCompleted, onDisposed: onDisposed)
        
        return disposable
    }
}
