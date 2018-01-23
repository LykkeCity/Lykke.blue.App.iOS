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
    
    let clientCodesTrigger = Variable<Void?>(nil)
    
    lazy var clientCodesViewModel: ClientCodesViewModel = {
        
        return ClientCodesViewModel(
            smsCodeForRetrieveKey: self.buttonsBar.forwardButton
                .rx.tap
                .withLatestFrom(self.codeField.rx.text)
                .filterNil(),
            dependency: (
                authManager: LWRxAuthManager.instance,
                keychainManager: LWKeychainManager.instance()
            )
        )
    }()
    
    fileprivate let phone = LWKeychainManager.instance().personalData().phone ?? ""
    
    fileprivate lazy var loadingViewModel = {
        return LoadingViewModel([
            self.clientCodesViewModel.loadingViewModel.isLoading
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
