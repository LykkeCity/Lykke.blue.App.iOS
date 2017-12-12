//
//  ValidatePinViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/30/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class ValidatePinViewController: UIViewController {

    var pinViewController: PinPadViewController! {
        return (self.childViewControllers.first{ $0 is PinPadViewController }) as! PinPadViewController
    }
    
    lazy var viewModel : PinGetViewModel = {
        return PinGetViewModel(submit: self.trigger.asObservable().filterNil() )
    }()
    
    let trigger = Variable<Void?>(nil)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }
}

fileprivate extension PinGetViewModel {
    func bind(toViewController vc: ValidatePinViewController) -> [Disposable] {
        return [
            vc.pinViewController.pin.asObservable().filterNil().bind(to: pin),
            pin.asObservable().filterEmpty().map{ _ in Void() }.bind(to: vc.trigger),
            loading.bind(to: vc.rx.loading),
            result.asObservable().subscribe(onNext: { [weak vc] _ in
                vc?.pinViewController.numbers.value = []
            }),
            result.asObservable().filterError().bind(to: vc.rx.error),
            result.asObservable().filterSuccess().filter{ !$0.isPassed }.subscribe(onNext: { [weak vc] data in
                vc?.pinViewController.dotsContainer.shake()
            }),
            result.asObservable().filterSuccess().filter{ $0.isPassed }.subscribe(onNext: { [weak vc] pinSecurity in
                guard let vc = vc else { return }
                
                PinPresenter.dismiss(vc, animated: true)
            })
        ]
    }
}
