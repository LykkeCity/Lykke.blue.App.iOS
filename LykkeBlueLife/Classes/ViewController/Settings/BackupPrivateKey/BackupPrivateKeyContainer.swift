//
//  BackupPrivateKeyContainer.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 30.01.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BackupPrivateKeyContainer: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    
    fileprivate let disposeBag = DisposeBag()
    fileprivate var backupTitle: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = self
        
        closeButton.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak vc] in
                vc?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        // Do any additional setup after loading the view.
    }

    override func setupTitle(_ title: String) {
        backupTitle = title
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "navigationVC" {
            if let backupTitle = backupTitle {
                segue.destination.setupTitle(backupTitle)
            }
        }
    }

}
