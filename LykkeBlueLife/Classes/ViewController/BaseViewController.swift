//
//  MasterViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/24/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class BaseViewController: UIViewController {
    
    let loadingView: LoadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action:  #selector(goBack))
        navigationItem.setLeftBarButton(backButton, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showLoadingView(isLoading: Bool){
        DispatchQueue.main.async {
            if isLoading {
                UIApplication.shared.keyWindow?.addSubview(self.loadingView)
            } else {
                self.loadingView.removeFromSuperview()
            }
        }
    }
    
    func goBack(){
        navigationController?.popViewController(animated: true)
    }
    
}

