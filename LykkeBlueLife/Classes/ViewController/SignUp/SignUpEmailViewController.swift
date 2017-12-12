//
//  SignUpEmailViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/18/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift
import TextFieldEffects
import RxKeyboard
import Toaster

class SignUpEmailViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var buttonsBar: ButtonsBarView!
    @IBOutlet weak var emailField: HoshiTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonsBarBottom: NSLayoutConstraint!
    
    private let kURLPrivacyString = "myapp://privacypolicity"
    private let kURLTermsString = "myapp://terms"
    private let kURLNoneString = "myapp://none"
    
    var triggerButton: UIButton = UIButton(type: UIButtonType.custom)
    var triggerButtonFake: UIButton = UIButton(type: UIButtonType.custom)
    
    lazy var viewModel : SignUpEmailViewModel = {
        return SignUpEmailViewModel(submit: self.buttonsBar.forwardButton.rx.tap.asObservable() )
    }()
    
    lazy var accountExistsViewModel: AccountExistViewModel = {
        return AccountExistViewModel(email: self.emailField.rx.text.asObservable().filterNil())
    }()
    
    lazy var confirmEmailViewModel : SignUpEnterPinViewModel={
        return SignUpEnterPinViewModel(submitConfirmPin: self.triggerButton.rx.tap.asObservable(), submitResendPin: self.triggerButtonFake.rx.tap.asObservable() )
    }()
    
     var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.setTransparent()
        buttonsBar.backwardButton.isHidden = true
        setupFormUX(disposedBy: disposeBag)
        
        scrollView
            .drive(toConstraint: buttonsBarBottom)
            .disposed(by: disposeBag)
        
        scrollView
            .bindToToaster()
            .disposed(by: disposeBag)
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        accountExistsViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }

    @IBAction func closeDidTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let verifyEmail = segue.destination as? SignUpVerifyEmailViewController, let email = sender as? String {
           verifyEmail.email = email
        }
    }
}

fileprivate extension SignUpEmailViewModel {
    func bind(toViewController vc: SignUpEmailViewController) -> [Disposable] {
        return [
            vc.emailField.rx.text.asObservable()
                .filterNil()
                .bind(to: email),
            
            isValid.asDriver(onErrorJustReturn: false)
                .drive(vc.buttonsBar.forwardButton.rx.isEnabled),
            
            loading
                .bind(to: vc.rx.loading),
            
            result.asObservable()
                .filterError()
                .bind(to: vc.rx.error),
            
            result.asObservable()
                .filterSuccess()
                .subscribe(onNext: {[weak vc] data in
                    vc?.performSegue(withIdentifier: AppConstants.Segue.showVerifyEmail, sender: data.email)
                })
        ]
    }
}

fileprivate extension AccountExistViewModel {
    func bind(toViewController vc: SignUpEmailViewController) -> [Disposable] {
        return [
            isLoading
                .map{ !$0 }
                .bind(to: vc.buttonsBar.forwardButton.rx.isEnabled),
            
            accountExistObservable
                .map{ !$0.isRegistered }
                .bind(to: vc.buttonsBar.forwardButton.rx.isEnabled),
            
            accountExistObservable
                .filter{ $0.isRegistered }
                .subscribe(onNext: { _ in Toast(text: "A user with the same email already exists.").show() })
        ]
    }
}

extension SignUpEmailViewController: InputForm {
    
    var submitButton: UIButton! {
        return buttonsBar.forwardButton
    }
    
    var textFields: [UITextField] {
        return [
            emailField
        ]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
}
