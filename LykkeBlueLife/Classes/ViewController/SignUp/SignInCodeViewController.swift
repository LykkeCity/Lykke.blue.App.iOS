//
//  SignInCodeViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 23.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift
import TextFieldEffects
import Toaster

class SignInCodeViewController: UIViewController {

    @IBOutlet weak var codeField: HoshiTextField!
    @IBOutlet weak var buttonsBar: ButtonsBarView!
    @IBOutlet weak var buttonsBarBottom: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var disposeBag = DisposeBag()
    
    lazy var confirmPinViewModel: SignUpPhoneConfirmPinViewModel = {
        return SignUpPhoneConfirmPinViewModel(
            submitConfirmPin: self.buttonsBar.forwardButton.rx.tap.asObservable(),
            submitResendPin: Observable.never()
        )
    }()
    
    lazy var phoneNumberViewModel: PhoneNumberViewModel = {
        return PhoneNumberViewModel(saveSubmit: Observable.just(Void()))
    }()
    
    let clientCodesTrigger = Variable<Void?>(nil)
    
    lazy var clientCodesViewModel: ClientCodesViewModel = {
        return ClientCodesViewModel(
            trigger: self.clientCodesTrigger.asObservable().filterNil(),
            dependency: (
                authManager: LWRxAuthManager.instance,
                keychainManager: LWKeychainManager.instance()
            )
        )
    }()
    
    fileprivate let phone = LWKeychainManager.instance().personalData().phone ?? ""
    
    fileprivate lazy var loadingViewModel = {
        return LoadingViewModel([
            self.clientCodesViewModel.loadingViewModel.isLoading,
            self.confirmPinViewModel.loading,
            self.phoneNumberViewModel.loading
        ])
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFormUX(disposedBy: disposeBag)

        scrollView
            .drive(toConstraint: buttonsBarBottom)
            .disposed(by: disposeBag)
        
        scrollView
            .bindToToaster()
            .disposed(by: disposeBag)
        
        phoneNumberViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        confirmPinViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        clientCodesViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        buttonsBar
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

fileprivate extension PhoneNumberViewModel {
    func bind(toViewController vc: SignInCodeViewController) -> [Disposable] {
        
        phonenumber.value = vc.phone
        
        return [
            saveSettingsResult.asObservable().filterSuccess().subscribe(onNext: { phone in
                Toast(text: "SMS code sent.").show()
            }),
            saveSettingsResult.asObservable().filterError().bind(to: vc.rx.error)
        ]
    }
}

fileprivate extension ClientCodesViewModel {
    func bind(toViewController vc: SignInCodeViewController) -> [Disposable] {
        return [
            errors.bind(to: vc.rx.error),
            encodeMainKeyObservable.subscribe(onNext: { [weak vc] encodedKey in
                vc?.rx.hideLoading()
                AppCoordinator.shared.showHome(fromViewController: vc)
            })
        ]
    }
}


fileprivate extension SignUpPhoneConfirmPinViewModel {
    func bind(toViewController vc: SignInCodeViewController) -> [Disposable] {
        phone.value = vc.phone
        
        let error = Observable.merge(
            resultConfirmPin.asObservable().filterError(),
            resultConfirmPin.asObservable().filterSuccess().filter{ !$0.isPassed }.map{ _ in ["Message": "Invalid code. Please try again."] },
            resultResendPin.asObservable().filterError()
        )
        
        return [
            vc.codeField.rx.text.asObservable().filterNil().bind(to: pin),
            isValid.bind(to: vc.buttonsBar.forwardButton.rx.isEnabled),
            error.bind(to: vc.rx.error),
            resultConfirmPin.asObservable().filterSuccess().filter{ $0.isPassed }.map{ _ in Void() }.bind(to: vc.clientCodesTrigger),
            resultResendPin.asObservable().filterSuccess().subscribe(onNext: { verificationSet in
                Toast(text: "Successfuly resent code.").show()
            })
        ]
    }
}

extension SignInCodeViewController: InputForm {
    
    var submitButton: UIButton! {
        return buttonsBar.forwardButton
    }
    
    var textFields: [UITextField] {
        return [codeField]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
}
