//
//  TwitterViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/22/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import WalletCore
import TwitterKit
import RxSwift
import RxCocoa
import Toaster

class TwitterViewController: TWTRTimelineViewController {
    
    fileprivate let client = TWTRAPIClient()
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Twitter.sharedInstance().rx.isLoggedIn
            .subscribe(onNext: { [weak self, client] isLoggedIn in
                self?.dataSource = isLoggedIn ?
                    TWTRSearchTimelineDataSource(searchQuery: AppConstants.Twitter.hashTag, apiClient: client) :
                        TwitterTimelineDataSource(apiClient: client)
            })
            .disposed(by: disposeBag)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigation()
    }
    
    private func setupNavigation() {
        guard let parent = parent as? HomePageViewController else { return }
        parent.navigationItem.title = "home"
        parent.navigationItem.rightBarButtonItem?.customView?.alpha = 1.0
        parent.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: AppTheme.navigationTitleFont,
                                                                   NSForegroundColorAttributeName: AppTheme.labelDarkColor]
        parent.customizePageControl(withSelectedColor: AppTheme.pageControlSelectedColor)
    }
    
    func postTapped() {
        
        guard Twitter.sharedInstance().sessionStore.hasLoggedInUsers() else {
            // Log in, and then check again
            Twitter.sharedInstance().login(withViewController: self)
            return
        }
        
        // App must have at least one logged-in user to compose a Tweet
        let composer = TWTRComposerViewController.emptyComposer(forViewController: self)
        present(composer, animated: true, completion: nil)
    }
}

fileprivate extension Twitter {
    func login(withViewController vc: TwitterViewController) {
        let login = rx.login()
        
        login
            .filterSuccess()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak vc] session in
                guard let vc = vc else { return }
                let composer = TWTRComposerViewController.emptyComposer(forViewController: vc)
                vc.present(composer, animated: true, completion: nil)
            })
            .disposed(by: vc.disposeBag)
        
        login
            .filterError()
            .bind(to: vc.rx.error)
            .disposed(by: vc.disposeBag)
        
//        logIn { session, error in
//            if session != nil { // Log in succeeded
////                TwitterState.instance.isLoggedIn.onNext(true)
//                let composer = TWTRComposerViewController.emptyComposer(forViewController: vc)
//                vc.present(composer, animated: true, completion: nil)
//            } else {
//                let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
//                    (result : UIAlertAction) -> Void in
//                }
//
//                alert.addAction(okAction)
//
//                vc.present(alert, animated: false, completion: nil)
//            }
//        }
    }
}

fileprivate extension TWTRComposerViewController {
    static func emptyComposer(forViewController vc: TwitterViewController) -> TWTRComposerViewController {
        let composer = TWTRComposerViewController(initialText: AppConstants.Twitter.hashTag + " ", image: nil, videoURL: nil)
        composer.delegate = vc
        
        return composer
    }
}

extension TwitterViewController: TWTRComposerViewControllerDelegate {
    func composerDidSucceed(_ controller: TWTRComposerViewController, with tweet: TWTRTweet) {
        Toast(text: "Your tweet will be posted shortly.").show()
    }
    
    func composerDidFail(_ controller: TWTRComposerViewController, withError error: Error) {
        Observable
            .just(["Message": error.localizedDescription])
            .bind(to: rx.error)
            .disposed(by: disposeBag)
    }
    
    func composerDidCancel(_ controller: TWTRComposerViewController) {
        
    }
}
