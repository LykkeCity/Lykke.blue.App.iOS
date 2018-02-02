//
//  CommunityViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/22/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import WalletCore

class CommunityViewController: UIViewController {
    @IBOutlet weak var ringImageView: UIImageView!
    @IBOutlet weak var treeImageView: UIImageView!
    @IBOutlet weak var treeLabel: UILabel!
    @IBOutlet weak var popupContainer: UIView!
    @IBOutlet weak var communityCaption: UILabel!
    @IBOutlet weak var community: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var treeCount: UILabel!
    @IBOutlet weak var amountInBaseAsset: UILabel!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var tradeButton: UIButton!
    
    let didAppear = PublishSubject<Void>()
    let willDisappear = PublishSubject<Void>()
    let didLayoutSubviews = PublishSubject<Void>()
    
    var isVisible = true
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate lazy var viewModel: CommunityViewModel = {
        let triggerRefresh = Observable<Void>
            .interval(5.0)
            .filter{ [weak self] in self?.isVisible ?? false }
        
        return CommunityViewModel(triggerRefresh: triggerRefresh)
    }()
    
    private var hidesTooltip: Bool {
        return UserDefaults.standard.value(forKey: UserDefaultsKeys.communityInfoTooltipShownBefore) != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        popupContainer.isHidden = hidesTooltip
        claimReferralLinkIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear.onNext(Void())
        setupNavigation()
        isVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        willDisappear.onNext(Void())
        isVisible = false
        
        guard let parent = parent as? HomePageViewController else { return }
        
        UIApplication.shared.statusBarStyle = .default
        parent.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: AppTheme.navigationTitleFont,
                                                                           NSForegroundColorAttributeName: AppTheme.labelDarkColor]
        parent.navigationController?.navigationBar.setOpaque()
        
        if let image = UIImage(named: AppConstants.ImageName.profileNoImage) {
            parent.profileNavButton.setImage(image, for: .normal)
        }
        
        parent.pageControlSetOpaque()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        didLayoutSubviews.onNext(Void())
    }
    
    private func setupNavigation() {
        parent?.navigationItem.title = "discover"
        parent?.navigationItem.rightBarButtonItem?.customView?.alpha = 0.0
    }

    fileprivate func setupUIForTreesAvailable() {
        guard let parent = parent as? HomePageViewController else { return }
        
        UIApplication.shared.statusBarStyle = .lightContent
        ringImageView.image = UIImage(named: AppConstants.ImageName.communityGreenRing)
        treeImageView.image = UIImage(named: AppConstants.ImageName.treeAssetIcon)
        for label in [treeLabel, communityCaption, community] {
            label?.textColor = .white
        }
        for view in [questionLabel, popupContainer] {
            view?.isHidden = true
        }
        
        tradeButton.titleLabel?.textColor = .white
        
        parent.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: AppTheme.navigationTitleFont,
                                                                          NSForegroundColorAttributeName: UIColor.white]
        parent.navigationController?.navigationBar.setTransparent()
        parent.navigationItem.leftBarButtonItem?.image = UIImage(named: AppConstants.ImageName.profileNoImageWhite)!
        parent.pageControlSetTransparent()
        parent.customizePageControl(withSelectedColor: UIColor.white)
        
        if let image = UIImage(named: AppConstants.ImageName.profileNoImageWhite) {
            parent.profileNavButton.setImage(image, for: .normal)
        }
        
        background.isHidden = false 
    }
    
    private func claimReferralLinkIfNeeded() {
        guard let refId = UserDefaults.standard.value(forKey: UserDefaultsKeys.referralLinkId) as? String,
            let isNewClient = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNewClient) as? Bool else { return }
        
        LWRxBlueAuthManager.instance.claimReferralLink.request(withParams:
            ReferralLinkClaimPacket.Body(referralLinkId: refId, isNewClient: isNewClient))
            .filterSuccess()
            .subscribe(onNext: {_ in
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.referralLinkId)
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.isNewClient)
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func removeInfoTooltop(_ sender: UIGestureRecognizer) {
        popupContainer.isHidden = true
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.communityInfoTooltipShownBefore)
        UserDefaults.standard.synchronize()
    }
    
}

fileprivate extension CommunityViewModel {
    func bind(toViewController vc: CommunityViewController) -> [Disposable] {
        
        let setupUIForTreesAvailable = Observable
            .combineLatest(
                zeroBalance.filter{!$0}.map{ _ in Void() }.asObservable(),
                vc.didAppear.asObservable(),
                vc.didLayoutSubviews.asObservable()
            )
            .subscribe(onNext: { [weak vc] _ in
                vc?.setupUIForTreesAvailable()
            })
        
        return [
            communityUsersCount.drive(vc.community.rx.text),
            treesCount.drive(vc.treeCount.rx.text),
            amountInBaseAsset.drive(vc.amountInBaseAsset.rx.text),
            setupUIForTreesAvailable,
            loadingViewModel.isLoading.bind(to: vc.rx.loading)
        ]
    }
}
