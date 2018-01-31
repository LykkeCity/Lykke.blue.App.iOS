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

class SignUpPasswordViewController: UIViewController {

    @IBOutlet weak var buttonsBar: ButtonsBarView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reenterPassTextFiel: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonsBarBottom: NSLayoutConstraint!
    
    var email: String!
    
    lazy var viewModel : SignUpRegistrationViewModel = {
        return SignUpRegistrationViewModel(submit: self.buttonsBar.forwardButton.rx.tap.asObservable() )
    }()
    
    var disposeBag = DisposeBag()
    
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
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}

fileprivate extension SignUpRegistrationViewModel {
    func bind(toViewController vc: SignUpPasswordViewController) -> [Disposable] {
        
        clientInfo.value = LWDeviceInfo.instance().clientInfo()
        email.value = vc.email
        
        return [
            vc.passwordTextField.rx.text.filterNil().bind(to: password),
            vc.reenterPassTextFiel.rx.text.filterNil().bind(to: reenterPassword),
            isValid.bind(to: vc.buttonsBar.forwardButton.rx.isEnabled),
            loading.bind(to: vc.rx.loading),
            result.asObservable().filterError().bind(to: vc.rx.error),
            result.asObservable().filterSuccess().subscribe(onNext: { [weak vc] registration in
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isNewClient)
                UserDefaults.standard.synchronize()
                vc?.performSegue(withIdentifier: AppConstants.Segue.showAddPhoneNumber, sender: nil)
            })
        ]
    }
}

extension SignUpPasswordViewController: InputForm {
    
    var submitButton: UIButton! {
        return buttonsBar.forwardButton
    }
    
    var textFields: [UITextField] {
        return [passwordTextField, reenterPassTextFiel]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
}
