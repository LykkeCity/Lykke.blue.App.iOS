//
//  SignUpPasswordViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/21/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class SignUpPasswordViewController: BaseViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reenterPassTextFiel: UITextField!
    @IBOutlet weak var hintTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var email = ""
    
    lazy var viewModel : SignUpRegistrationViewModel={
        return SignUpRegistrationViewModel(submit: self.registerButton.rx.tap.asObservable() )
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel.clientInfo.value = LWDeviceInfo.instance().clientInfo()
        viewModel.email.value = self.email
        // emailTextField.rx.text.map({$0 ?? ""}).bindTo(viewModel.email).addDisposableTo(disposeBag)
        passwordTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        reenterPassTextFiel.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.reenterPassword)
            .disposed(by: disposeBag)
        
        hintTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.hint)
            .disposed(by: disposeBag)
        
        //from the viewModel
        viewModel.isValid
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.registerButton.isEnabled = !isLoading
        }).disposed(by: disposeBag)

        viewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: {errorData in
                UIHelper.showErrorMessage(messageDict: errorData, forViewController: self)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {pack in
                //gonext
                print("Success registration")
                /*self.dismiss(animated: true) {
                    UserDefaults.standard.set("true", forKey: "loggedIn")
                    print("user is logged in")
                }*/
                //self.goToNextScreen()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.tempUsername = self.email
                appDelegate.tempPassword = self.passwordTextField.text!
                self.goSetPhone()
                
            })
            .disposed(by: disposeBag)
    }

    func goToNextScreen() {
        let signInStoryBoard = UIStoryboard.init(name: "SignInUp", bundle: nil)
        let signUpPasswordVC = signInStoryBoard.instantiateViewController(withIdentifier: "CreatePin") as! PinSetViewController
        
        passwordTextField.resignFirstResponder()
        reenterPassTextFiel.resignFirstResponder()
        hintTextField.resignFirstResponder()
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpPasswordVC, animated: true)
    }
    
    func goSetPhone(){
        
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let screenVC = storyboard.instantiateViewController(withIdentifier: "SettingsChangePhone") as! SettingsChangePhoneViewController
        
        screenVC.isItRegistration = true
        screenVC.isPinSet = false
        self.view.endEditing(true)
        self.navigationController?.pushViewController(screenVC, animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserInterface()
    }
    
    func setUserInterface() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationItem.hidesBackButton = false
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
