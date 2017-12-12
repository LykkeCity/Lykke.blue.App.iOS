//
//  HomePageViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/22/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import WalletCore

class HomePageViewController: UIPageViewController {
    
    @IBOutlet weak var profileNavButton: UIButton!
    
    fileprivate var screens: [UIViewController] = []
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        initializePages()
        postPledgesIfNeeded()
        
        LWRxAuthManager.instance
            .triggerSaveCache()
            .disposed(by: disposeBag)
    }
    
    /// Delegate to TwitterViewController::postTapped()
    @IBAction func twitterLogin(_ sender: Any) {
        guard let twitterViewController = (childViewControllers.first{$0 is TwitterViewController}) as? TwitterViewController else {
            return
        }
        
        twitterViewController.postTapped()
    }
    
    public func customizePageControl(withSelectedColor color: UIColor) {
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [HomePageViewController.self])
        pageControl.pageIndicatorTintColor = .lightGray
        
        pageControl.currentPageIndicatorTintColor = color
    }
    
    private func setup() {
        dataSource = self
        view.backgroundColor = .white
    }
    
    private func initializePages() {
        let storyboard = UIStoryboard(name: AppConstants.Storyboard.main, bundle: nil)
        let twitter = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.twitter)
        let community = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.community)
        
        screens = [twitter, community]
        setViewControllers([twitter], direction: .forward, animated: true, completion: nil)
    }
    
    private func postPledgesIfNeeded() {
        if let footprint = UserDefaults.standard.value(forKey: UserDefaultsKeys.footprintValue) as? Int,
            let netPositive = UserDefaults.standard.value(forKey: UserDefaultsKeys.netPositiveValue) as? Int  {
            
            LWRxBlueAuthManager.instance.pledgePost.request(withParams:
                PledgePostPacket.Body(climatePositive: netPositive, footprint: footprint * 1000))
                .filterSuccess()
                .subscribe(onNext: {_ in
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.footprintValue)
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.netPositiveValue)
                })
                .disposed(by: disposeBag)
        }
    }
}

extension HomePageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = screens.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = index + 1
        
        guard screens.count > nextIndex else {
            return nil
        }
        
        return screens[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = screens.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = index - 1
        
        guard previousIndex >= 0, screens.count > previousIndex else {
            return nil
        }

        return screens[previousIndex]
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return screens.count
    }
}

