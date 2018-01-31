//
//  SignInViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/17/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift
import TextFieldEffects

class SignInViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailField: HoshiTextField!
    @IBOutlet weak var passwordField: HoshiTextField!
    @IBOutlet weak var buttonsBar: ButtonsBarView!
    @IBOutlet weak var buttonsBarBottom: NSLayoutConstraint!
    
    lazy var viewModel: LogInViewModel = {
        return LogInViewModel(submit: self.buttonsBar.forwardButton.rx.tap.asObservable() )
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
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    }
    
    @IBAction func closeDidTap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pinViewController = segue.destination as? SignInPinViewController, let authPacket = sender as? LWPacketAuthentication {
            pinViewController.authPacket = authPacket
        }
    }
}

fileprivate extension LogInViewModel {
    func bind(toViewController vc: SignInViewController) -> [Disposable] {
        clientInfo.value = LWDeviceInfo.instance().clientInfo()
        
        return [
            vc.emailField.rx.text.asObservable().filterNil().bind(to: email),
            vc.passwordField.rx.text.asObservable().filterNil().bind(to: password),
            isValid.bind(to: vc.buttonsBar.forwardButton.rx.isEnabled),
            loading.bind(to: vc.rx.loading),
            result.asObservable().filterError().bind(to: vc.rx.error),
            result.asObservable().filterSuccess().subscribe(onNext: { [weak vc] auth in
                vc?.performSegue(withIdentifier: AppConstants.Segue.showSignInPin, sender: auth)
            })
        ]
    }
}

extension SignInViewController: InputForm {
    
    var submitButton: UIButton! {
        return buttonsBar.forwardButton
    }
    
    var textFields: [UITextField] {
        return [emailField, passwordField]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
}
