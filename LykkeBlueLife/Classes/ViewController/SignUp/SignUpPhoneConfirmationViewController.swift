//
//  SignUpPhoneConfirmationViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 22.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import WalletCore
import RxSwift
import RxCocoa
import TextFieldEffects
import Toaster

class SignUpPhoneConfirmationViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var codeField: HoshiTextField!
    @IBOutlet weak var buttonsBar: ButtonsBarView!
    @IBOutlet weak var buttonsBarBottom: NSLayoutConstraint!
    
    lazy var confirmPinViewModel: SignUpPhoneConfirmPinViewModel = {
        return SignUpPhoneConfirmPinViewModel(
            submitConfirmPin: self.buttonsBar.forwardButton.rx.tap.asObservable(),
            submitResendPin: Observable.never()
        )
    }()
        
    var phone: String!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupFormUX(disposedBy: disposeBag)
        
        scrollView
            .drive(toConstraint: buttonsBarBottom)
            .disposed(by: disposeBag)
        
        buttonsBar
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        confirmPinViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        buttonsBar.backwardButton.isHidden = true
        
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

fileprivate extension SignUpPhoneConfirmPinViewModel {
    func bind(toViewController vc: SignUpPhoneConfirmationViewController) -> [Disposable] {
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
            loading.bind(to: vc.rx.loading),
            resultConfirmPin.asObservable().filterSuccess().filter{ $0.isPassed }.subscribe(onNext: { [weak vc] verification in
                vc?.performSegue(withIdentifier: AppConstants.Segue.showSetPin, sender: nil)
            }),
            resultResendPin.asObservable().filterSuccess().subscribe(onNext: { verificationSet in
                Toast(text: "Successfuly resent code.").show()
            })
        ]
    }
}

extension SignUpPhoneConfirmationViewController: InputForm {
    
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
