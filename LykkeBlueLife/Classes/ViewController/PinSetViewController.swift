//
//  PinSetViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/30/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class PinSetViewController: BaseViewController {
    
    @IBOutlet weak var pin1TextField: UITextField!
    @IBOutlet weak var pin2TextField: UITextField!
    @IBOutlet weak var pin3TextField: UITextField!
    @IBOutlet weak var pin4TextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    var pin = ""
    
    var triggerButton: UIButton = UIButton(type: UIButtonType.custom)
    
    lazy var viewModel: PinSetViewModel = {
        return PinSetViewModel(submit: self.triggerButton.rx.tap.asObservable() )
    }()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.isEnabled = false
        
        pin1TextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        pin2TextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        pin3TextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        pin4TextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        if(pin != "" )
        {
            viewModel.pin.value = self.pin
            viewModel.loading.subscribe(onNext: {isLoading in
                self.nextButton.isEnabled = !isLoading
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
                    let signInStoryBoard = UIStoryboard.init(name: "SignInUp", bundle: nil)
                    let signUpPasswordVC = signInStoryBoard.instantiateViewController(withIdentifier: "ShakeScreen") //as! PinSetViewController
                    
                    self.view.endEditing(true)
                    self.navigationController?.pushViewController(signUpPasswordVC, animated: true)
                })
                .disposed(by: disposeBag)
            
        }
        else{
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goNext(_ sender:UIButton)
    {
        if(self.pin != "")
        {
            let pinCode = pin1TextField.text! + pin2TextField.text! + pin3TextField.text! + pin4TextField.text!
            if(pin != pinCode)
            {
                let message = "Pin code does not match"
                print(message)
                let alertController = UIAlertController(title: Localize("utils.error"), message: message, preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
                    (result : UIAlertAction) -> Void in
                    print("OK")
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            else{
                self.triggerButton.sendActions(for: .touchUpInside)
            }
        }
        else{
            goAgain()
        }
    }
    
    func textFieldDidChange() {
        //your code
        let pincode = pin1TextField.text! + pin2TextField.text! + pin3TextField.text! + pin4TextField.text!
        if(pincode.characters.count == 4)
        {
            nextButton.isEnabled = true
        }
        else{
            nextButton.isEnabled = false
        }
        
    }
    
    func goAgain(){
        let signInStoryBoard = UIStoryboard.init(name: "SignInUp", bundle: nil)
        let vc = signInStoryBoard.instantiateViewController(withIdentifier: "CreatePin") as! PinSetViewController
        vc.pin = pin1TextField.text! + pin2TextField.text! + pin3TextField.text! + pin4TextField.text!
        pin1TextField.resignFirstResponder()
        pin2TextField.resignFirstResponder()
        pin3TextField.resignFirstResponder()
        pin4TextField.resignFirstResponder()
        self.view.endEditing(true)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension PinSetViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
