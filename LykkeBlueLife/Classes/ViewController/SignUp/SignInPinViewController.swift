//
//  SignInPinViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 23.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WalletCore

class SignInPinViewController: UIViewController {

    var pinViewController: PinPadViewController! {
        return (self.childViewControllers.first{ $0 is PinPadViewController }) as! PinPadViewController
    }
    
    lazy var viewModel : PinGetViewModel = {
        return PinGetViewModel(submit: self.trigger.asObservable().filterNil() )
    }()
    
    let trigger = Variable<Void?>(nil)
    
    var authPacket: LWPacketAuthentication!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

fileprivate extension PinGetViewModel {
    func bind(toViewController vc: SignInPinViewController) -> [Disposable] {
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
                vc?.performSegue(withIdentifier: AppConstants.Segue.showSignInSMSCode, sender: pinSecurity)
            })
        ]
    }
}
