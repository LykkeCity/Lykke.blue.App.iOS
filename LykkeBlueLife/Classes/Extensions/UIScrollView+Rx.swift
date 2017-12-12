//
//  UIScrollView+Rx.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 21.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxKeyboard
import Toaster

extension UIScrollView {
    func drive(toConstraint constraint: NSLayoutConstraint) -> Disposable {
        return RxKeyboard.instance.frame
            .drive(onNext: { [weak self] keyboardFrame in
                guard
                    let scrollView = self,
                    let rootView = scrollView.window?.rootViewController?.view
                else {
                    return
                }
                
                let scrollViewFrame = rootView.convert(scrollView.bounds, from: scrollView)
                let intersectionHeight = scrollViewFrame.intersection(keyboardFrame).height
                constraint.constant = intersectionHeight
            })
    }
    
    func bindToToaster() -> Disposable {
        return RxKeyboard.instance.frame
            .drive(onNext: { [weak self] keyboardFrame in
                guard
                    let scrollView = self,
                    let rootView = scrollView.window?.rootViewController?.view
                    else {
                        return
                }
                
                let scrollViewFrame = rootView.convert(scrollView.bounds, from: scrollView)
                let intersectionHeight = scrollViewFrame.intersection(keyboardFrame).height
                ToastView.appearance().bottomOffsetPortrait = intersectionHeight
            })
    }
}
