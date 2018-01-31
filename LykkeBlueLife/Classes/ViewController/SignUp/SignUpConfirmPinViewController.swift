//
//  SIgnUpConfirmPinViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 22.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignUpConfirmPinViewController: UIViewController {

    var pin: String!
    
    private var pinViewController: PinPadViewController! {
        return (self.childViewControllers.first{ $0 is PinPadViewController }) as! PinPadViewController
    }
    
    lazy var viewModel : SignUpPinSetViewModel = {
        return SignUpPinSetViewModel(submit: self.confirmedPin.filter{ $0 }.map{ _ in Void() })
    }()
    
    lazy var confirmedPin: Observable<Bool> = {
        let pin = self.pin
        return self.pinViewController.pin.asObservable().filterNil().map{ $0 == pin }
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.pin.value = pin
        
        confirmedPin
            .bind(toPinPad: pinViewController)
            .disposed(by: disposeBag)
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

fileprivate extension SignUpPinSetViewModel {
    func bind(toViewController vc: SignUpConfirmPinViewController) -> [Disposable] {
        return [
            loading.bind(to: vc.rx.loading),
            result.asObservable().filterError().bind(to: vc.rx.error),
            result.asObservable().filterSuccess().subscribe(onNext: { [weak vc] pinSet in
                vc?.performSegue(withIdentifier: AppConstants.Segue.showGeneratePrivateKey, sender: nil)
            })
        ]
    }
}

fileprivate extension ObservableType where Self.E == Bool {
    func bind(toPinPad pinPad: PinPadViewController) -> Disposable {
        return filter{ !$0 }
            .subscribe(onNext: { _ in
                pinPad.numbers.value = []
                pinPad.dotsContainer.shake()
            })
    }
}
