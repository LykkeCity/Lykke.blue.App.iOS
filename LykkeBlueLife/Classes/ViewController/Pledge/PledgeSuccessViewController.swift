//
//  PledgeSuccessViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/28/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import WalletCore
import RxSwift
import RxCocoa

class PledgeSuccessViewController: UIViewController {
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var forward: UIButton!
    @IBOutlet weak var invite: InviteButton!
    
    private let disposeBag = DisposeBag()
    
    private lazy var viewModel: ReferralLinkViewModel = {
        return ReferralLinkViewModel(trigger: self.invite.rx.tap.asObservable())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        if LWKeychainManager.instance().isAuthenticated {
            register.isHidden = true
            login.isHidden = true
        } else {
            forward.isHidden = true
            invite.isHidden = true
        }
    }
    
}

extension ReferralLinkViewModel {
    func bind(toViewController vc: UIViewController) -> [Disposable] {
        return [
            referralLinkUrl.subscribe(onNext: {[weak vc] url in
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                vc?.present(activityViewController, animated: true, completion: nil)
            }),
            loadingViewModel.isLoading.bind(to: vc.rx.loading)
        ]
    }
}
