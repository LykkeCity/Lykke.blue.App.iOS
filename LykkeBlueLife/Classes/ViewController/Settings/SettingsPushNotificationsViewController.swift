//
//  SettingsPushNotificationsViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/29/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class SettingsPushNotificationsViewController: BaseViewController {
//PushNotificationsViewModel
    @IBOutlet weak var pushNotificationsSwitch: UISwitch!
    var triggerButton: UIButton = UIButton(type: UIButtonType.custom)
    
    lazy var viewModel : PushNotificationsViewModel={
        return PushNotificationsViewModel(submit:self.triggerButton.rx.tap.asObservable())
    }()
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.showLoadingView(isLoading: isLoading)
        }).disposed(by: disposeBag)
        
        viewModel.on.value = pushNotificationsSwitch.isOn
        
        viewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: {errorData in
                UIHelper.showErrorMessage(messageDict: errorData, forViewController: self)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {pack in
//                /LWCache.instance().baseAssetId = pack.identity
                //self.goBack()
                if(self.pushNotificationsSwitch.isOn == true)
                {
                    LWCache.instance().pushNotificationsStatus = PushNotificationsStatus.enabled
                }
                else{
                    LWCache.instance().pushNotificationsStatus = PushNotificationsStatus.disabled
                }
            })
            .disposed(by: disposeBag)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(LWCache.instance().pushNotificationsStatus == PushNotificationsStatus.enabled)
        {
            pushNotificationsSwitch.isOn = true
        }
        else{
            pushNotificationsSwitch.isOn = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func pNotValueChanged(sender: UISwitch) {
        viewModel.on.value = pushNotificationsSwitch.isOn
        self.triggerButton.sendActions(for: .touchUpInside)
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
