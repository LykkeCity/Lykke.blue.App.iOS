//
//  SIgnUpSetPinViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 22.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SignUpSetPinViewController: UIViewController {

    var pinViewController: PinPadViewController? {
        return (self.childViewControllers.first{ $0 is PinPadViewController }) as? PinPadViewController
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinViewController?.pin.asObservable().filterNil()
            .subscribe(onNext: { [weak self] pin in
                self?.performSegue(withIdentifier: AppConstants.Segue.showConfirmPin, sender: pin)
            })
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
        if let confirmPin = segue.destination as? SignUpConfirmPinViewController, let pin = sender as? String {
            confirmPin.pin = pin
        }
    }
}
