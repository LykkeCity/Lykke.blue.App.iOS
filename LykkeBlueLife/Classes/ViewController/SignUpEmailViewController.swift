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

class SignUpEmailViewController: BaseViewController, UITextViewDelegate {

    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var termsTextView: UITextView!
    
    private let kURLPrivacyString = "myapp://privacypolicity"
    private let kURLTermsString = "myapp://terms"
    private let kURLNoneString = "myapp://none"
    
    var triggerButton: UIButton = UIButton(type: UIButtonType.custom)
    var triggerButtonFake: UIButton = UIButton(type: UIButtonType.custom)
    
    lazy var viewModel : SignUpEmailViewModel={
        return SignUpEmailViewModel(submit: self.signUpButton.rx.tap.asObservable() )
    }()
    
    lazy var confirmEmailViewModel : SignUpEnterPinViewModel={
        return SignUpEnterPinViewModel(submitConfirmPin: self.triggerButton.rx.tap.asObservable(), submitResendPin: self.triggerButtonFake.rx.tap.asObservable() )
    }()
    
     var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.email)
            .disposed(by: disposeBag)
        

        
        //from the viewModel
        viewModel.isValid
            .bind(to: signUpButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.signUpButton.isEnabled = !isLoading
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
                self.goToNextScreen()
            })
            .disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    func goToNextScreen() {
        let signInStoryBoard = UIStoryboard.init(name: "SignInUp", bundle: nil)
        let signUpPasswordVC = signInStoryBoard.instantiateViewController(withIdentifier: "ValidatePin") as! SignUpEnterPinViewController
        signUpPasswordVC.email = emailTextField.text!
        emailTextField.resignFirstResponder()
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpPasswordVC, animated: true)
    }*/

    func goToNextScreen() {
        let signInStoryBoard = UIStoryboard.init(name: "SignInUp", bundle: nil)
        let signUpPasswordVC = signInStoryBoard.instantiateViewController(withIdentifier: "SignUpPassword") as! SignUpPasswordViewController
        signUpPasswordVC.email = self.emailTextField.text!
        emailTextField.resignFirstResponder()

        
        self.view.endEditing(true)
        self.navigationController?.pushViewController(signUpPasswordVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUserInterface()
        setupUser()
    }
    
    func setUserInterface() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationItem.hidesBackButton = false
    }
    
    func setupUser() {
        
        emailTextField.placeholder = NSLocalizedString(
            "Email",
            tableName: "SkyFloatingLabelTextField",
            comment: "placeholder for Email field"
        )
        emailTextField.selectedTitle = NSLocalizedString(
            "Email",
            tableName: "SkyFloatingLabelTextField",
            comment: "selected title for Email field"
        )
        emailTextField.title = NSLocalizedString(
            "Email",
            tableName: "SkyFloatingLabelTextField",
            comment: "title for Email field"
        )
        
        applySkyscannerTheme(textField: emailTextField)
        
        //let borderColor = UIColorWithRGBA(235, 237, 239, 1)
        //let borderColor = UIColor.black
        
        //add the rounded corners
        DispatchQueue.main.async(execute: {
            self.emailTextField.roundCorners(corners: [.allCorners], radius: 10.0, border: true)
            
        });
        
        let attributedString = NSMutableAttributedString(string: "By pressing contininue you agree to our Terms and conditions and Privacy policy")
        attributedString.addAttributes([
            //NSFontAttributeName: UIFont(name: "UIFontWeightThin", size: 14.0)!,
           // NSForegroundColorAttributeName: UIColor(red: 0 / 255.0, green: 140 / 255.0, blue: 255 / 255.0, alpha: 1.0),
            NSLinkAttributeName: kURLTermsString
            ],
                                       range: NSRange(location: 40, length: 20))
        attributedString.addAttributes([
            //NSFontAttributeName: UIFont(name: "UIFontWeightThin", size: 14.0)!,
            //NSForegroundColorAttributeName: UIColor(red: 0 / 255.0, green: 140 / 255.0, blue: 255 / 255.0, alpha: 1.0),
            NSLinkAttributeName: kURLPrivacyString
            ],
                                       range: NSRange(location: 65, length: 14))
        
        termsTextView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 0 / 255.0, green: 140 / 255.0, blue: 255 / 255.0, alpha: 1.0) ]
        termsTextView.attributedText = attributedString
        termsTextView.textColor = UIColor(red: 140 / 255.0, green: 148 / 255.0, blue: 160 / 255.0, alpha: 1.0)
        termsTextView.isEditable = false
        termsTextView.isSelectable = true
        termsTextView.textAlignment = .center
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        var message = String()
        if (URL.absoluteString == kURLPrivacyString) {
            // Do whatever you want here as the action to the user pressing your 'actionString'
            message = "Privacy Policy"
            print(URL)
        }
        
        if (URL.absoluteString == kURLTermsString) {
            message = "Terms and Conditions"
        }
        
        if !message.isEmpty {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        present(alert, animated: true)
        }
        return false
    }
    
    func tapFunction(sender:UITapGestureRecognizer) {
        print("tap working")
    }
    
    func applySkyscannerTheme(textField: SkyFloatingLabelTextField) {
        textField.tintColor = UIColor(red: 63 / 255, green: 77 / 255, blue: 96 / 255, alpha: 1.0)
        textField.textColor = UIColor(red: 63 / 255, green: 77 / 255, blue: 96 / 255, alpha: 1.0)
        textField.selectedTitleColor = UIColor(red: 140 / 255, green: 148 / 255, blue: 160 / 255, alpha: 1.0)
        textField.titleColor = UIColor(red: 140 / 255, green: 148 / 255, blue: 160 / 255, alpha: 1.0)
        
        // Set custom fonts for the title, placeholder and textfield labels
        /*textField.titleLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
         textField.placeholderFont = UIFont(name: "AppleSDGothicNeo-Light", size: 18)
         textField.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)*/
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
