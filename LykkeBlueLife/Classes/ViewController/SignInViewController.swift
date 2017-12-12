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

class SignInViewController: BaseViewController {
    
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var loginButton: UIButton!
    var seePassword = UIButton()

    
    lazy var viewModel: LogInViewModel = {
        return LogInViewModel(submit: self.loginButton.rx.tap.asObservable() )
    }()

    var disposeBag = DisposeBag()
    
    var textFields: [SkyFloatingLabelTextField] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupUI()
    }
    
    private func setupViewModel() {
        viewModel.clientInfo.value = LWDeviceInfo.instance().clientInfo()
        
        emailTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        //from the viewModel
        viewModel.isValid
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.loginButton.isEnabled = !isLoading
            self.showLoadingView(isLoading: isLoading)
            
        }).disposed(by: disposeBag)
        
        viewModel.result
            .debug("print: result", trimOutput: false)
            .drive(onNext: {_ in})
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: {errorData in
                UIHelper.showErrorMessage(messageDict: errorData, forViewController: self)
            })
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {[weak self] pack in
                guard let srongSelf = self else { return }
                
                if pack.personalData == nil || pack.personalData.phone == nil || pack.personalData.phone == "" {
                    srongSelf.goSetPhone(isPinSet: pack.isPinEntered)
                } else if !pack.isPinEntered {
                    srongSelf.goCreatePin()
                } else {
                    srongSelf.goEnterPin()
                }
            })
            .disposed(by: disposeBag)
        
        textFields = [emailTextField, passwordTextField]
    }
    
    private func setupUI() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        emailTextField.placeholder = NSLocalizedString(
            "Username/e-mail",
            tableName: "SkyFloatingLabelTextField",
            comment: "placeholder for Username/e-mail field"
        )
        emailTextField.selectedTitle = NSLocalizedString(
            "Username/e-mail",
            tableName: "SkyFloatingLabelTextField",
            comment: "selected title for Username/e-mail field"
        )
        emailTextField.title = NSLocalizedString(
            "Username/e-mail",
            tableName: "SkyFloatingLabelTextField",
            comment: "title for Username/e-mail field"
        )
        
        passwordTextField.placeholder = NSLocalizedString(
            "Password",
            tableName: "SkyFloatingLabelTextField",
            comment: "placeholder for Password field"
        )
        passwordTextField.selectedTitle = NSLocalizedString(
            "Password",
            tableName: "SkyFloatingLabelTextField",
            comment: "selected title for Password field"
        )
        passwordTextField.title = NSLocalizedString(
            "Password",
            tableName: "SkyFloatingLabelTextField",
            comment: "title for Password field"
        )
        
        applySkyscannerTheme(textField: passwordTextField)
        applySkyscannerTheme(textField: emailTextField)
        
        //addd the button to the right in textfield
        seePassword = passwordTextField.addButtonOnTextField("viewIcnW50.png")
        seePassword.addTarget(self, action: #selector(seePass(_:)), for: .touchUpInside)
        
        emailTextField.roundCorners(corners: [.topLeft, .topRight], radius: 10.0, border: false)
        passwordTextField.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10.0, border: false)
    }
    
    func goSetPhone(isPinSet: Bool){
        
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let screenVC = storyboard.instantiateViewController(withIdentifier: "SettingsChangePhone") as! SettingsChangePhoneViewController
        
        screenVC.isItRegistration = true
        screenVC.isPinSet = isPinSet
        self.view.endEditing(true)
        self.navigationController?.pushViewController(screenVC, animated: true)
    }
    
    func goCreatePin() {
        let signInStoryBoard = UIStoryboard.init(name: "SignInUp", bundle: nil)
        let signUpPasswordVC = signInStoryBoard.instantiateViewController(withIdentifier: "CreatePin") as! PinSetViewController
        
        emailTextField.resignFirstResponder()
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpPasswordVC, animated: true)
    }
    
    func goEnterPin() {
        let signInStoryBoard = UIStoryboard.init(name: "SignInUp", bundle: nil)
        let signUpPasswordVC = signInStoryBoard.instantiateViewController(withIdentifier: "ValidatePinCode")
        
        emailTextField.resignFirstResponder()
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpPasswordVC, animated: true)
    }
    
    func seePass(_ sender: UIButton) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    }
    
    // MARK: - Styling the text fields to the Skyscanner theme
    
    func applySkyscannerTheme(textField: SkyFloatingLabelTextField) {
        
        textField.tintColor = .white
        textField.textColor = .white
        textField.selectedTitleColor = .white
        textField.titleColor = .white
    }
}
