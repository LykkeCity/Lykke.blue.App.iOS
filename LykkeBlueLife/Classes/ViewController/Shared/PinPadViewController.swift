//
//  PinPadViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 22.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PinPadViewController: UIViewController {

    @IBOutlet weak var first: UIButton!
    @IBOutlet weak var second: UIButton!
    @IBOutlet weak var third: UIButton!
    @IBOutlet weak var fourth: UIButton!
    @IBOutlet weak var numpad: NumPadView!
    @IBOutlet weak var dotsContainer: UIStackView!
    
    let numbers = Variable<[Int]>([])
    
    private let disposeBag = DisposeBag()
    
    static let maxPinSize = 4
    
    let pin = Variable<String?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numpad
            .bind(toNumbers: numbers)
            .disposed(by: disposeBag)
        
        numbers.asObservable()
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        numbers.asObservable()
            .filter{ $0.count == PinPadViewController.maxPinSize }
            .map{ $0.reduce("") { "\($0)\($1)"} }
            .bind(to: pin)
            .disposed(by: disposeBag)
    }
}

fileprivate extension ObservableType where Self.E == [Int] {
    func bind(toViewController vc: PinPadViewController) -> [Disposable] {
        return [
            map{ $0.count >= 1 }.bind(to: vc.first.rx.isSelected),
            map{ $0.count >= 2 }.bind(to: vc.second.rx.isSelected),
            map{ $0.count >= 3 }.bind(to: vc.third.rx.isSelected),
            map{ $0.count >= 4 }.bind(to: vc.fourth.rx.isSelected)
        ]
    }
}

fileprivate extension NumPadView {
    func bind(toNumbers numbers: Variable<[Int]>) -> [Disposable] {
        return [
            tap
                .filter{ _ in numbers.value.count < PinPadViewController.maxPinSize }
                .subscribe(onNext: { number in numbers.value.append(number)}),
            
            deleteNumber.rx.tap.asObservable()
                .subscribe(onNext: { _ = numbers.value.popLast()})
        ]
    }
}
