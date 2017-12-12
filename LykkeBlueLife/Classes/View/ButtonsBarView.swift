//
//  ButtonsBarView.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 20.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxSwift

@IBDesignable
class ButtonsBarView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)!
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib("ButtonsBarView")
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func bind(toViewController vc: UIViewController) -> Disposable {
        return backwardButton.rx.tap.asObservable()
            .subscribe(onNext: {[weak vc] in
                vc?.navigationController?.popViewController(animated: true)
            })
    }
}
