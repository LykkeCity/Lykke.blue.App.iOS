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
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate var backupTitle: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = backupTitle ?? titleLabel.text
        
        beginButton.rx.tap
            .flatMap { return ValidatePinViewController.presentPinViewController(from: self, allowToClose: true) }
            .delay(0.1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.performSegue(withIdentifier: AppConstants.Segue.showPrivateKeyWords, sender: nil)
            })
            .disposed(by: disposeBag)
        
    }

    override func setupTitle(_ title: String) {
        backupTitle = title
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
