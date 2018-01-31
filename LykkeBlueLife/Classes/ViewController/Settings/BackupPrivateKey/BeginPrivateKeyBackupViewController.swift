//
//  BeginPrivateKeyBackupViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 31.01.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BeginPrivateKeyBackupViewController: UIViewController {

    @IBOutlet weak var beginButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        beginButton.rx.tap
            .flatMap { return ValidatePinViewController.presentPinViewController(from: self, allowToClose: true) }
            .delay(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.performSegue(withIdentifier: "showPrivateKeyWords", sender: nil)
            })
            .disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
