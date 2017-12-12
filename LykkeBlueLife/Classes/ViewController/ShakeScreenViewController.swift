//
//  ShakeScreenViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/31/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class ShakeScreenViewController: BaseViewController {

    var shakeCount : Int = 0
    var isShakingNow : Bool = false
    @IBOutlet weak var shakesLabel: UILabel!
    
    
    var triggerButton: UIButton = UIButton(type: UIButtonType.custom)
    var triggerButtonLogin: UIButton = UIButton(type: UIButtonType.custom)
    
    
    
    lazy var viewModel : ClientKeysViewModel={
        return ClientKeysViewModel(submit: self.triggerButton.rx.tap.asObservable() )
    }()
    
    lazy var loginViewModel : LogInViewModel={
        return LogInViewModel(submit: self.triggerButtonLogin.rx.tap.asObservable() )
    }()
    
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.applicationSupportsShakeToEdit = true
        shakeCount=0
        isShakingNow = false
        
        self.setUpLoginViewModel()
        // Do any additional setup after loading the view.
        
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.showLoadingView(isLoading: isLoading)
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
                self.triggerButtonLogin.sendActions(for: .touchUpInside)

            })
            .disposed(by: disposeBag)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == UIEventSubtype.motionShake)
        {
            shakeCount += 1
            shakesLabel.text = String(shakeCount)
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if (motion == UIEventSubtype.motionShake)
        {
            if(shakeCount == 3)
            {
                self.createKeys()
                
            }
        }
    }

    func createKeys(){

        if(LWPrivateKeyManager.shared().isPrivateKeyLykkeEmpty())
        {
            
            LWPrivateKeyManager.shared().savePrivateKeyLykke(fromSeedWords: LWPrivateKeyManager.generateSeedWords12())
            viewModel.pubKey.value = LWPrivateKeyManager.shared().publicKeyLykke
            viewModel.encodedPrivateKey.value = LWPrivateKeyManager.shared().encryptedKeyLykke
            self.triggerButton.sendActions(for: .touchUpInside)
            /*
            [[LWPrivateKeyManager shared] savePrivateKeyLykkeFromSeedWords:[LWPrivateKeyManager generateSeedWords12]];
            [self setLoading:YES];
            [[LWAuthManager instance] requestSaveClientKeysWithPubKey:[LWPrivateKeyManager shared].publicKeyLykke encodedPrivateKey:[LWPrivateKeyManager shared].encryptedKeyLykke];
            */
        }
    }
    
    func login()
    {
        
    }
    
    func setUpLoginViewModel()
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        loginViewModel.clientInfo.value = LWDeviceInfo.instance().clientInfo()
        loginViewModel.email.value = appDelegate.tempUsername
        loginViewModel.password.value = appDelegate.tempPassword
        
        
        loginViewModel.loading.subscribe(onNext: {isLoading in
            self.showLoadingView(isLoading: isLoading)
            
        }).disposed(by: disposeBag)
        
        
        loginViewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: {errorData in
                UIHelper.showErrorMessage(messageDict: errorData, forViewController: self)
                
            })
            .disposed(by: disposeBag)
        
        loginViewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true) {
                    UserDefaults.standard.set("true", forKey: "loggedIn")
                    print("user is logged in")
                }
                
            })
            .disposed(by: disposeBag)
    }

}
