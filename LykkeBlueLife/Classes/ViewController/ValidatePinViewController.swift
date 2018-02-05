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

    @IBOutlet weak var closeButton: UIButton!
    
    var pinViewController: PinPadViewController! {
        return (self.childViewControllers.first{ $0 is PinPadViewController }) as! PinPadViewController
    }
    
    lazy var viewModel : PinGetViewModel = {
        return PinGetViewModel(submit: self.trigger.asObservable().filterNil() )
    }()
    
    let trigger = Variable<Void?>(nil)
    let pinValidationResult = PublishSubject<Bool>()
    
    let disposeBag = DisposeBag()
    
    var allowToClose: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeButton.isHidden = !allowToClose
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        closeButton.rx.tap.subscribe(onNext: { [weak self] _ in
            if let vc = self {
                PinPresenter.dismiss(vc, animated: true)
            }
        })
        .disposed(by: disposeBag)
    }
    
    func pinEntryCompleted(success: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        pinValidationResult.onNext(success)
        dismiss(animated: animated, completion: completion)
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
                vc?.pinValidationResult.onNext(false)
            }),
            result.asObservable().filterSuccess().filter{ $0.isPassed }.subscribe(onNext: { [weak vc] pinSecurity in
                guard let vc = vc else { return }
                vc.pinValidationResult.onNext(true)
                PinPresenter.dismiss(vc, animated: true)
            })
        ]
    }
}

// MARK: - Instantiation extensions

extension ValidatePinViewController {
    static func pinPadViewController() -> ValidatePinViewController {
        let storyboard = UIStoryboard(name: AppConstants.Storyboard.signInUp, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.validatePin) as! ValidatePinViewController
        return viewController
    }
    
    static func presentPinViewController(from viewController: UIViewController, allowToClose: Bool = false) -> Observable<Void> {
        let pinViewController = pinPadViewController()
        pinViewController.allowToClose = allowToClose
        PinPresenter.present(from: viewController, viewControllerToPresent: pinViewController)
        return pinViewController.pinValidationResult
            .filter { $0 }
            .map { _ in return () }
            .shareReplay(1)
    }
}

