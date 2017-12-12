//
//  SettingChangePhoneViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/25/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//


import UIKit
import WalletCore
import RxCocoa
import RxSwift

class SettingsChangePhoneViewController : BaseViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var savePhoneButton: UIButton!
    var isItRegistration : Bool = false
    var isPinSet : Bool = true
    lazy var viewModel : PhoneNumberViewModel={
        return PhoneNumberViewModel(saveSubmit: self.savePhoneButton.rx.tap.asObservable() )
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(LWKeychainManager.instance().personalData() != nil && LWKeychainManager.instance().personalData().phone != nil)
        {
            phoneTextField.text = LWKeychainManager.instance().personalData().phone!
        }
        
       
        // Do any additional setup after loading the view.
        phoneTextField.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.phonenumber)
            .disposed(by: disposeBag)
        
        
        
        //from the viewModel
        viewModel.isValid
            .bind(to: savePhoneButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.savePhoneButton.isEnabled = !isLoading
        }).disposed(by: disposeBag)
        
        viewModel.loadingSaveChanges.subscribe(onNext: {isLoading in
            self.savePhoneButton.isEnabled = !isLoading
        }).disposed(by: disposeBag)

        
        viewModel.saveSettingsResult.asObservable()
            .filterError()
            .subscribe(onNext: {errorData in
                UIHelper.showErrorMessage(messageDict: errorData, forViewController: self)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.saveSettingsResult.asObservable()
            .filterSuccess()
            .subscribe(onNext: {pack in
                //success
                self.goValidatePin()
            })
            .disposed(by: disposeBag)
        
        //////////// load contry codes
        
        viewModel.countryCodesResult.asObservable()
            .filterSuccess()
            .subscribe(onNext: {packet in
                //list LWPacketCountryCodes
                
            })
            .disposed(by: disposeBag)
        
        //SettingsPhoneValidatePin
    }
    
    func goValidatePin() {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let screenVC = storyboard.instantiateViewController(withIdentifier: "SettingsPhoneValidatePin") as! SettingsPhoneConfirmViewController
        screenVC.isItRegistration = self.isItRegistration
        screenVC.isPinSet = self.isPinSet
        screenVC.phone = self.phoneTextField.text!
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
        if((LWKeychainManager.instance().personalData()) != nil)
        {
            phoneTextField.text = LWKeychainManager.instance().personalData().phone!
        }
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
