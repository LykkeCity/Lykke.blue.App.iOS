//
//  SignUpAddPhoneViewController.swift
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

class SignUpAddPhoneViewController: UIViewController {

    @IBOutlet weak var buttonsBarBottom: NSLayoutConstraint!
    @IBOutlet weak var buttonsBar: ButtonsBarView!
    @IBOutlet weak var phoneField: HoshiTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private let disposeBag = DisposeBag()
    
    lazy var viewModel : PhoneNumberViewModel = {
        return PhoneNumberViewModel(saveSubmit: self.buttonsBar.forwardButton.rx.tap.asObservable() )
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
        
        buttonsBar
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        buttonsBar.backwardButton.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let phoneConfirmation = segue.destination as? SignUpPhoneConfirmationViewController, let phone = sender as? String {
            phoneConfirmation.phone = phone
        }
    }
}

fileprivate extension PhoneNumberViewModel {
    func bind(toViewController vc: SignUpAddPhoneViewController) -> [Disposable] {
        return [
            vc.phoneField.rx.text.asObservable().filterNil().bind(to: phonenumber),
            isValid.bind(to: vc.buttonsBar.forwardButton.rx.isEnabled),
            loading.bind(to: vc.rx.loading),
            loadingSaveChanges.bind(to: vc.rx.loading),
            saveSettingsResult.asObservable().filterError().bind(to: vc.rx.error),
            saveSettingsResult.asObservable().filterSuccess().subscribe(onNext: { [weak vc] phoneVerification in
                vc?.performSegue(withIdentifier: AppConstants.Segue.showVerifyPhone, sender: phoneVerification.phone)
            })
        ]
    }
}

extension SignUpAddPhoneViewController: InputForm {
    
    var submitButton: UIButton! {
        return buttonsBar.forwardButton
    }
    
    var textFields: [UITextField] {
        return [phoneField]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
}
