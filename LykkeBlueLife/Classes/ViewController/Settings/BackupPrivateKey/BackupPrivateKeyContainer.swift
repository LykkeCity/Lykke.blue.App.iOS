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
