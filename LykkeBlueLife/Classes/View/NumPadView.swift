//
//  NumPadView.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 22.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

@IBDesignable
class NumPadView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet weak var one: UIButton!
    @IBOutlet weak var two: UIButton!
    @IBOutlet weak var three: UIButton!
    @IBOutlet weak var four: UIButton!
    @IBOutlet weak var five: UIButton!
    @IBOutlet weak var six: UIButton!
    @IBOutlet weak var seven: UIButton!
    @IBOutlet weak var eight: UIButton!
    @IBOutlet weak var nine: UIButton!
    @IBOutlet weak var zero: UIButton!
    @IBOutlet weak var deleteNumber: UIButton!
    
    lazy var tap: Observable<Int> = {
        return Observable.merge(
            self.zero.rx.tap.asObservable().map{ 0 },
            self.one.rx.tap.asObservable().map{ 1 },
            self.two.rx.tap.asObservable().map{ 2 },
            self.three.rx.tap.asObservable().map{ 3 },
            self.four.rx.tap.asObservable().map{ 4 },
            self.five.rx.tap.asObservable().map{ 5 },
            self.six.rx.tap.asObservable().map{ 6 },
            self.seven.rx.tap.asObservable().map{ 7 },
            self.eight.rx.tap.asObservable().map{ 8 },
            self.nine.rx.tap.asObservable().map{ 9 }
        )
    }()
    
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
        view = loadViewFromNib("NumPadView")
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }

}
