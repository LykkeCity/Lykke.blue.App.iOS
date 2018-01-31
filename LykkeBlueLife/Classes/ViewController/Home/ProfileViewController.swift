//
//  ProfileViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/23/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import WalletCore
import RxSwift
import RxCocoa


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var noGoal: UILabel!
    @IBOutlet weak var takePledge: UIButton!
    @IBOutlet weak var pledgeNotTakenStackView: UIStackView!
    @IBOutlet weak var pledgeTakenStackView: UIStackView!
    @IBOutlet weak var pledgeInfoStackView: UIStackView!
    @IBOutlet weak var footprint: UILabel!
    @IBOutlet weak var netPositive: UILabel!
    @IBOutlet weak var remaining: UILabel!
    @IBOutlet weak var remainingTrees: UILabel!
    @IBOutlet weak var goalPercent: UILabel!
    @IBOutlet weak var progressView: ProgressCircle!
    @IBOutlet weak var goal: UILabel!
    @IBOutlet weak var netPositivePerYear: UILabel!
    @IBOutlet weak var invite: InviteButton!
    
    private let disposeBag = DisposeBag()
    
    lazy var personalData: PersonalDataViewModel = {
       return PersonalDataViewModel()
    }()
    
    lazy var viewModel: ProfilePledgeViewModel = {
        let triggerRefresh = Observable<Void>
            .interval(5.0)
            .filter{ _ in UIApplication.topViewController() is ProfileViewController }
        
       return ProfilePledgeViewModel(triggerRefresh: triggerRefresh)
    }()
    
    fileprivate lazy var loadingViewModel = {
        return LoadingViewModel([
                self.personalData.loading.isLoading,
                self.viewModel.loadingViewModel.isLoading
            ])
    }()
    
    private lazy var referralLinkViewModel: ReferralLinkViewModel = {
        return ReferralLinkViewModel(trigger: self.invite.rx.tap.asObservable())
    }()
    
    override func viewDidLoad() {
        customize()
        setupNavigation()
        setupViewModel()
    }
    
    private func setupViewModel() {
        personalData
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        viewModel.pledgeTaken
            .drive(onNext: {[weak self] pledgeTaken in
                self?.customizePledgeInfo(pledgeTaken: pledgeTaken)
            })
            .disposed(by: disposeBag)
        
        viewModel.percentFraction
            .drive(onNext: {[weak self] fraction in
                self?.progressView.progress = fraction
            })
            .disposed(by: disposeBag)
        
        referralLinkViewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
        
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
    }
    
    private func customize() {
        view.backgroundColor = AppTheme.profileBackgroundColor
        username.textColor = AppTheme.labelDarkColor
        noGoal.textColor = AppTheme.labelDarkColor
        takePledge.titleLabel?.textAlignment = .center
    }
    
    private func customizePledgeInfo(pledgeTaken: Bool) {
        pledgeNotTakenStackView.isHidden = pledgeTaken
        pledgeTakenStackView.isHidden = !pledgeTaken
        pledgeInfoStackView.isHidden = !pledgeTaken
    }
    
    private func setupNavigation() {
        navigationItem.title = AppConstants.Navigation.profileTitle
        let back = UIImage(named: AppConstants.ImageName.backNav)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: back, style: .plain, target: self, action: #selector(backTapped))
        navigationController?.navigationBar.tintColor = AppTheme.appBlue
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

}

fileprivate extension PersonalDataViewModel {
    func bind(toViewController vc: ProfileViewController) -> [Disposable] {
        return [email.drive(vc.username.rx.text)]
    }
}

fileprivate extension ProfilePledgeViewModel {
    func bind(toViewController vc: ProfileViewController) -> [Disposable] {
        return [
            footprintTons.drive(vc.footprint.rx.text),
            goalMultiplier.drive(vc.netPositive.rx.text),
            goalTons.drive(vc.goal.rx.text),
            remainingTons.drive(vc.remaining.rx.text),
            remainingTrees.drive(vc.remainingTrees.rx.text),
            percentComplete.drive(vc.goalPercent.rx.text),
            positiveTonsPerYear.drive(vc.netPositivePerYear.rx.text)
        ]
    }
}
