//
//  SettingsEmailConfirmViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/25/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class SettingsEmailConfirmViewController: BaseViewController {

    @IBOutlet weak var pin1TextField: UITextField!
    @IBOutlet weak var pin2TextField: UITextField!
    @IBOutlet weak var pin3TextField: UITextField!
    @IBOutlet weak var pin4TextField: UITextField!
    var email = ""
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var resendPinButton: UIButton!
    
    lazy var viewModel : SignUpEnterPinViewModel={
        return SignUpEnterPinViewModel(submitConfirmPin: self.validateButton.rx.tap.asObservable(), submitResendPin: self.resendPinButton.rx.tap.asObservable() )
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Do any additional setup after loading the view.
        pin1TextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.pin1)
            .disposed(by: disposeBag)
        pin2TextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.pin2)
            .disposed(by: disposeBag)
        pin3TextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.pin3)
            .disposed(by: disposeBag)
        pin4TextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.pin4)
            .disposed(by: disposeBag)
        
        viewModel.isValid
            .bind(to: validateButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.email.value = email
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.validateButton.isEnabled = !isLoading
            self.resendPinButton.isEnabled = !isLoading
            if(isLoading == false)
            {
                self.viewModel.pin1.value = self.viewModel.pin1.value
            }
        }).disposed(by: disposeBag)
        
        viewModel.resultConfirmPin.asObservable()
            .filterError()
            .subscribe(onNext: {errorData in
                UIHelper.showErrorMessage(messageDict: errorData, forViewController: self)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.resultConfirmPin.asObservable()
            .filterSuccess()
            .subscribe(onNext: {pack in
                if(pack.isPassed == true)
                {
                    print("Pin code during registration match")
                    self.goBackScreen()
                }
                else{
                    let alertController = UIAlertController(title: Localize("utils.error"), message: Localize("register.sms.error"), preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
                        (result : UIAlertAction) -> Void in
                        print("OK")
                    }
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                print("IsPassed: ", pack.isPassed)
            })
            .disposed(by: disposeBag)
        //resend pin
        viewModel.resultResendPin.asObservable()
            .filterError()
            .subscribe(onNext: {errorData in
                UIHelper.showErrorMessage(messageDict: errorData, forViewController: self)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.resultResendPin.asObservable()
            .filterSuccess()
            .subscribe(onNext: {pack in
                //success resend pin
                
            })
            .disposed(by: disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func goBackScreen() {
        
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
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
