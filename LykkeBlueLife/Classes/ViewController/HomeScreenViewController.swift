//
//  HomeScreenViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/17/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class HomeScreenViewController: BaseViewController {

    @IBOutlet weak var currenciesTableView: UITableView!
    
    var triggerGetWalletsButton: UIButton = UIButton(type: UIButtonType.custom)
    var didInitialize = false
    var disposeBag = DisposeBag()
    
    lazy var settingsViewModel : AppSettingsViewModel = {
        return AppSettingsViewModel()
    }()
    
    lazy var walletsModel : TradingWalletViewModel = {
        return TradingWalletViewModel(submit: self.triggerGetWalletsButton.rx.tap.asObservable())
    }()
    
    fileprivate let filter = Variable<BuyStep1ViewModel.CurrencyType?>(nil)
    fileprivate lazy var viewModel:BuyStep1ViewModel = {
        return BuyStep1ViewModel(
            filter: self.filter.asObservable().filterNil(),
            dependency: (
                authManager: LWRxAuthManager.instance,
                currencyExchanger: CurrencyExchanger()
            )
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LWAuthManager.instance().delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreenViewController.loadData), name: .loggedIn, object: nil)
    
        currenciesTableView.backgroundColor = UIColor.clear
        currenciesTableView.register(UINib(nibName: "LWPortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "LWPortfolioCurrencyTableViewCell")
        
        currenciesTableView.rx
            .modelSelected(BuyStep1CellViewModel.self)
            .map{$0.model}
            .subscribe(onNext: {[weak self] model in
                
        
                let buyStoryBoard = UIStoryboard.init(name: "BuySell", bundle: nil)
                guard let buyViewControllerStep3 = buyStoryBoard.instantiateViewController(withIdentifier: "BuySellStep1") as? BuySellStep1ViewController else {return}
                buyViewControllerStep3.assetPairModel = model
                
                
                self?.navigationController?.pushViewController(buyViewControllerStep3, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isAuth = LWKeychainManager.instance().isAuthenticated
        let personalData = LWKeychainManager.instance().personalData()
        
        if !isAuth || personalData == nil {
            showLoginScreen()
        } else {
            loadData()
        }
    }
    
    private func hideNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func signOutAction(_ sender:UIButton) {
        logout()
    }
    
    @IBAction func goToSettings(_ sender:UIButton) {
        let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
        let screenVC = storyboard.instantiateViewController(withIdentifier: "SettingsMain")
        
        self.view.endEditing(true)
        self.navigationController?.pushViewController(screenVC, animated: true)
    }

    func showLoginScreen(){
        navigationController?.dismiss(animated: false, completion: nil)
        let signInStory = UIStoryboard.init(name: "SignInUp", bundle: nil)
        let signUpNav = signInStory.instantiateViewController(withIdentifier: "SignInUpNav")
        present(signUpNav, animated: false, completion: nil)

    }
    
    func loadData() {
        if(didInitialize == false)
        {
            settingsViewModel.loading.subscribe(onNext: {isLoading in
                self.showLoadingView(isLoading: isLoading)
                if(isLoading == false)
                {
                    self.didInitialize = true
                }
            }).disposed(by: disposeBag)
            settingsViewModel.resultAccount.asObservable().filterSuccess().subscribe(onNext: {packet in
                packet.saveValues()
            }).disposed(by: disposeBag)
        }
        
        walletsModel.loading.subscribe(onNext: {isLoading in
            self.showLoadingView(isLoading: isLoading)

        }).disposed(by: disposeBag)
        walletsModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {wallet in
                //LWLykkeWalletsData
                var i = 1
                let startY = 80
                for w in wallet.lykkeData.wallets
                {
                    //w = LWSpotWallet
                    print("Currency id: %@", (w as! LWSpotWallet).identity)
                    //c33f03ea-bacd-4d26-a676-539ef5e8ec74
                    if((w as! LWSpotWallet).balance.doubleValue > 0.0 || (w as! LWSpotWallet).identity == "BTC" /*&& (w as! LWSpotWallet).name != nil*/|| (w as! LWSpotWallet).identity == "LKK"
                        || (w as! LWSpotWallet).identity == "c33f03ea-bacd-4d26-a676-539ef5e8ec74")
                    {
                        self.addAssetAsButton(frame: CGRect(x: 50, y: startY + (45 * i), width: 300, height: 40), wallet: w as! LWSpotWallet, tag: i)
                        i = i+1
                    }
                    //i = i+1
 
                }
                
            })
            .disposed(by: disposeBag)
        walletsModel.result.asObservable()
            .filterError()
            .subscribe(onNext: {errorData in
                UIHelper.showErrorMessage(messageDict: errorData, forViewController: self)
                
            })
            .disposed(by: disposeBag)
        // wallets

        /*
        viewModel.cellViewModels.asObservable()
            .bind(to: currenciesTableView.rx.items(cellIdentifier: "LWPortfolioCurrencyTableViewCell", cellType: LWPortfolioCurrencyTableViewCell.self)) { (row, element, cell) in
                cell.bind(toAssetPair: element)
            }
            .disposed(by: disposeBag)
        
        viewModel.loading.isLoading.subscribe(onNext: {[weak self] isLoading in
            // self?.setLoading(isLoading)
            self?.showLoadingView(isLoading: isLoading)
        }).disposed(by: disposeBag)
*/

        //this will get the wallets
        self.triggerGetWalletsButton.sendActions(for: .touchUpInside)
    }
    
    func addAssetAsButton(frame: CGRect, wallet: LWSpotWallet, tag: Int){
        let btn: TempButton = TempButton(frame: frame)//(frame: CGRect(x: 100, y: 400, width: 100, height: 50))
        btn.wallet = wallet
        btn.backgroundColor = UIColor.blue
        var ss = wallet.identity
        if (ss == nil)
        {
            ss = "NO NAME"
        }
        btn.setTitle(ss! + " " + String(wallet.balance.doubleValue), for: .normal)
        btn.addTarget(self, action: #selector(assetClicked), for: .touchUpInside)
        btn.tag = tag
        self.view.addSubview(btn)
    }
    
    func assetClicked(sender: UIButton!) {
        let btn: TempButton = sender as! TempButton
        let wallet = btn.wallet!
        self.chooseAction(wallet: wallet)

        
    }
    func chooseAction(wallet: LWSpotWallet){
        let alertController = UIAlertController(title: nil, message: "Choose action:", preferredStyle: UIAlertControllerStyle.alert)
        let buyAction = UIAlertAction(title: "Buy", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("Buy")
            self.goToBuyScreen(wallet: wallet)
        }
        let transferAction = UIAlertAction(title: "Send", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("Transfer")
            self.goToTranswerMoneyScreen(wallet: wallet)
        }
        let receiveAction = UIAlertAction(title: "Receive", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("Receive")
            self.goToReceiveMoneyScreen(wallet: wallet)
        }
        alertController.addAction(buyAction)
        alertController.addAction(transferAction)
        alertController.addAction(receiveAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func goToTranswerMoneyScreen(wallet: LWSpotWallet)
    {
        let buyStoryBoard = UIStoryboard.init(name: "BuySell", bundle: nil)
        guard let vc = buyStoryBoard.instantiateViewController(withIdentifier: "TranswerMoney") as? TransferByWAddressViewController else {return}
        vc.wallet = wallet
        
        
        // self.navigationController?.pushViewController(buyViewControllerStep3, animated: true)
        //self.present(buyViewControllerStep3, animated: false, completion: nil)
        
        let nvc = buyStoryBoard.instantiateViewController(withIdentifier: "NVC") as! UINavigationController
        nvc.pushViewController(vc, animated: true)
        self.present(nvc, animated: false, completion: nil)
    }
    
    func goToReceiveMoneyScreen(wallet: LWSpotWallet)
    {
        let buyStoryBoard = UIStoryboard.init(name: "BuySell", bundle: nil)
        guard let vc = buyStoryBoard.instantiateViewController(withIdentifier: "ReceiveMoney") as? ReceiveByWAddressViewController else {return}
        vc.wallet = wallet
        
        
        // self.navigationController?.pushViewController(buyViewControllerStep3, animated: true)
        //self.present(buyViewControllerStep3, animated: false, completion: nil)
        
        let nvc = buyStoryBoard.instantiateViewController(withIdentifier: "NVC") as! UINavigationController
        nvc.pushViewController(vc, animated: true)
        self.present(nvc, animated: false, completion: nil)
    }
    
    @IBAction func showCarbon(_ sender: Any) {
        let storyboard = UIStoryboard(name: AppConstants.Storyboard.pledge, bundle: nil)
        let carbonScreen = storyboard.instantiateViewController(withIdentifier: AppConstants.Screen.footprint)
        
        present(carbonScreen, animated: false, completion: nil)
    }
    
    func goToBuyScreen(wallet: LWSpotWallet)
    {
        let buyStoryBoard = UIStoryboard.init(name: "BuySell", bundle: nil)
        guard let buyViewControllerStep3 = buyStoryBoard.instantiateViewController(withIdentifier: "BuySellStep1") as? BuySellStep1ViewController else {return}
        buyViewControllerStep3.firstWallet = wallet
        
        
        // self.navigationController?.pushViewController(buyViewControllerStep3, animated: true)
        //self.present(buyViewControllerStep3, animated: false, completion: nil)
        
        let nvc = buyStoryBoard.instantiateViewController(withIdentifier: "NVC") as! UINavigationController
        nvc.pushViewController(buyViewControllerStep3, animated: true)
        self.present(nvc, animated: false, completion: nil)
    }
    
    func logout() {
        if LWKeychainManager.instance().isAuthenticated {
            LWAuthManager.instance().requestLogout()
        }
        LWKeychainManager.instance().clear();
        LWPrivateKeyManager.shared().logoutUser()
        LWKYCDocumentsModel.shared().logout()
        LWImageDownloader.shared().logout()
        LWEthereumTransactionsManager.shared().logout()
        LWMarginalWalletsDataManager.stop()
        
        showLoginScreen()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)

        super.viewDidDisappear(animated)
    }
}

extension HomeScreenViewController: LWAuthManagerDelegate {
    func authManagerDidNotAuthorized(_ manager: LWAuthManager!) {
        logout()
    }
}

fileprivate extension LWPortfolioCurrencyTableViewCell {
    func bind(toAssetPair assetPair: BuyStep1CellViewModel) {
        self.disposeBag = DisposeBag()
        
        assetPair.assetPairCodes
            .drive(cryptoNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        assetPair.capitalization
            .drive(percentLabel.rx.text)
            .disposed(by: disposeBag)
        
        assetPair.change
            .drive(valueLabel.rx.text)
            .disposed(by: disposeBag)
        
        assetPair.price
            .drive(cryptoValueLabel.rx.text)
            .disposed(by: disposeBag)
 
        
        assetPair.iconUrl
            .filterNil()
            .drive(iconImageView.rx.afImage)
            .disposed(by: disposeBag)
    }
}
