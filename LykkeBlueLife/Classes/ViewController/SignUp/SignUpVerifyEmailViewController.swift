//
//  SignUpVerifyEmailViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 21.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import TextFieldEffects
import Toaster

class SignUpVerifyEmailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonsBarView: ButtonsBarView!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var codeField: HoshiTextField!
    @IBOutlet weak var buttonsBarBottom: NSLayoutConstraint!
    
    lazy var viewModel : RegisterSendPinEmailViewModel = {
        return RegisterSendPinEmailViewModel(
            submitConfirmPin: self.buttonsBarView.forwardButton.rx.tap.asObservable(),
            submitResendPin: Observable.never()
        )
    }()
    
    var email: String!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerText.text = "we’ve sent a verification code to \(email!)"
        
        setupFormUX(disposedBy: disposeBag)
        
        scrollView
            .drive(toConstraint: buttonsBarBottom)
            .disposed(by: disposeBag)
        
        scrollView
            .bindToToaster()
            .disposed(by: disposeBag)
        
        buttonsBarView
            .bind(toViewController: self)
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
        if let password = segue.destination as? SignUpPasswordViewController, let email = sender as? String {
            password.email = email
        }
    }

}

fileprivate extension RegisterSendPinEmailViewModel {
    func bind(toViewController vc: SignUpVerifyEmailViewController) -> [Disposable] {
        email.value = vc.email
        
        let error = Observable.merge(
            resultConfirmPin.asObservable().filterError(),
            resultConfirmPin.asObservable().filterSuccess()
                .filter{ !$0.isPassed }
                .map{ _ in ["Message": "Invalid code. Please try again."] }
        )
        
        return [
            vc.codeField.rx.text.filterNil().bind(to: pin),
            isValid.bind(to: vc.buttonsBarView.forwardButton.rx.isEnabled),
            loading.bind(to: vc.rx.loading),
            error.bind(to: vc.rx.error),
            
            resultConfirmPin.asObservable()
                .filterSuccess()
                .filter{ $0.isPassed }
                .subscribe(onNext: {[weak vc] emailVerification in
                    vc?.performSegue(withIdentifier: AppConstants.Segue.showSetPassword, sender: emailVerification.email)
                }),
            
            resultResendPin.asObservable().filterError().bind(to: vc.rx.error),
            resultResendPin.asObservable().filterSuccess().subscribe(onNext: { _ in
                Toast(text: "Success resent pin").show()
            })
        ]
    }
}

extension SignUpVerifyEmailViewController: InputForm {
    
    var submitButton: UIButton! {
        return buttonsBarView.forwardButton
    }
    
    var textFields: [UITextField] {
        return [codeField]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
}
