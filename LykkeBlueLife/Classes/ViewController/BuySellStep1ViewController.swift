//
//  LWBuyStep3ViewController.swift
//  LykkeWallet
//
//  Created by Bozidar Nikolic on 7/7/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class BuySellStep1ViewController: BaseViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var buyWithCurrencyLbl: UILabel!
    @IBOutlet weak var unitsValue: UILabel!
    @IBOutlet weak var unitsTitle: UILabel!
    @IBOutlet weak var unitsCurrency: UILabel!
    @IBOutlet weak var unitsAmount : UITextField!
    @IBOutlet weak var priceCurrency: UILabel!
    @IBOutlet weak var totalCurrency: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var buyWithAvLbl: UILabel!
    @IBOutlet weak var buyWithValue: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var priceValue: UILabel!
    @IBOutlet weak var priceAmount: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    
    var dataPicker : UIPickerView = UIPickerView()
    var txtField: UITextField = UITextField()
    var disposeBag = DisposeBag()
    let authManager: LWRxAuthManager = LWRxAuthManager.instance
    let currencyChanger : CurrencyExchanger = CurrencyExchanger()
    var askOrBid: Bool = false
    
    //    lazy var assetPairModel: LWAssetPairModel  = {
    //        let assetPair = LWAssetPairModel.assetPair(withDict: ["Accuracy":"3", "BaseAssetId":"BTC", "Group":"LYKKE", "Id":"BTCUSD", "Inverted":"0", "InvertedAccuracy": "8", "Name":"BTC/USD", "QuotingAssetId":"USD"])
    //        return assetPair!
    //    }()
    
    var assetPairModel: LWAssetPairModel = LWAssetPairModel()
    let assetModel = Variable<LWAssetModel?>(nil)
    let wallet = Variable<LWSpotWallet?>(nil)
    let wallets = Variable<[LWSpotWallet]>([])
    
    var firstWallet : LWSpotWallet = LWSpotWallet()
    
    let bid = Variable<Bool?>(nil)
    lazy var viewModel: BLBuySellStep1ViewModel = self.viewModelFactory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        if(self.assetPairModel.quotingAssetId == nil)
        {
            unitsCurrency.text = LWCache.instance().baseAssetId
        }*/
        
        if(self.firstWallet.identity == nil)
        {
            unitsCurrency.text = LWCache.instance().baseAssetId
        }

        
        //this is hardcoded
        //        let decryptPrivateKeyManager = LWPrivateKeyManager.shared()
        //        decryptPrivateKeyManager?.decryptLykkePrivateKeyAndSave("5b98a88a4a542ad6d76784b172db9e62001412da420b3d7874bc2998eec93145b45d1e69fd4aa1eff683a40a821676dbb622a29dcda184cd41d80e21375133a8")
        
        confirmBtn.layer.borderWidth = 1.0
        confirmBtn.layer.borderColor =  UIColor.white.cgColor
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        txtField.inputView = dataPicker
        self.view.addSubview(txtField)
        addDoneButton(txtField, selector: #selector(doneAction))
        addDoneButton(unitsAmount, selector: #selector(doneUnitsAction))
        
        unitsAmount.attributedPlaceholder = NSAttributedString(string: "0.0",
                                                               attributes: [NSForegroundColorAttributeName: UIColor.white])
        
        imageHeight.constant =  Display.height
        fillViewModelInput()
        addBindings()
    }
    
    func addBindings() {
        viewModel.unitsInBaseAsset
            .drive(unitsValue.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.assetName
            .drive(unitsCurrency.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.priceInBaseAsset
            .drive(priceValue.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.price
            .drive(priceAmount.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletTotal
            .drive(totalAmount.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletTotalAv
            .drive(buyWithAvLbl.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletTotalInBaseAsset
            .drive(totalValue.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletAssetCode
            .drive(buyWithCurrencyLbl.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletAssetCode
            .drive(priceCurrency.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.walletAssetCode
            .drive(totalCurrency.rx.text)
            .disposed(by: disposeBag)
        
               // viewModel.currentPriceCurrencyInBaseAsset
               //     .drive(buyWithValue.rx.text)
               //     .disposed(by: disposeBag)
        
    }
    
    func fillViewModelInput() {
        bid.value =  getAskOrBid()
        
        viewModel.nonEmptyWallets
            .bind(to: wallets)
            .disposed(by: disposeBag)
        
        wallets.asObservable()
            .bind(to: dataPicker.rx.itemTitles) { (row, element) in
                return element.identity //return element.name //
            }
            .disposed(by: disposeBag)
        
        dataPicker.rx.itemSelected.asObservable()
            .filter{[weak self] _ in self?.wallets.value.isNotEmpty ?? false}
            .map{$0.row}
            .filter{[weak self] in $0 < self?.wallets.value.endIndex ?? 0}
            .map{[weak self] in self?.wallets.value[$0]}.filterNil()
            .bind(to: self.wallet)
            .disposed(by: disposeBag)
        /*
        
        //TODO: To be implemented
        authManager.allAssets
            //            .requestAsset(byId: self.assetPairModel.baseAssetId)
            .requestAsset(byId:self.assetPairModel.quotingAssetId)
            .filterSuccess()
            .filterNil()
            .bind(to: assetModel)
            .disposed(by: disposeBag)
        //
         */
 
        authManager.allAssets
            //            .requestAsset(byId: self.assetPairModel.baseAssetId)
            .request(byId:self.firstWallet.identity)
            .filterSuccess()
            .filterNil()
            .bind(to: assetModel)
            .disposed(by: disposeBag)
    }
    
    func updateBuyCurrency() {
        print("Update buy currency")
    }
    
    func viewModelFactory() -> BLBuySellStep1ViewModel {
        
        let unitsObservable = unitsAmount.rx.textInput.text.asObservable()
            .replaceNilWith("0.0")
            .map{$0.decimalValue}
            .replaceNilWith(0.0)
            .shareReplay(1)
        
        
        let assetModelObservable = assetModel.asObservable().filterNil().shareReplay(1)
        let walletObservable = wallet.asObservable().filterNil().shareReplay(1)
        let bidObservable = bid.asObservable().filterNil().shareReplay(1)
        
        return BLBuySellStep1ViewModel(
            input: (
                units:      unitsObservable,
                asset:      assetModelObservable,
                wallet:     walletObservable,
                bid:        bidObservable
            ),
            currencyExchanger: CurrencyExchanger()
        )
    }
    
    
    func getAskOrBid() -> Bool {
        return askOrBid
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func doneUnitsAction() {
        unitsAmount.resignFirstResponder()
    }
    
    func doneAction() {
        txtField.resignFirstResponder()
       // buyWithAvLbl.text =
    }
    
    @IBAction func showPicker(_ sender: UIButton) {
        txtField.becomeFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        txtField.resignFirstResponder()
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    @IBAction func testAction(_ sender: UIButton) {

    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
    
        if let unitsAmaountValue = Double(unitsAmount.text!) {
            
            if unitsAmount.text != "" && buyWithCurrencyLbl.text != "" && unitsAmaountValue>0{
                
                let buyStoryBoard = UIStoryboard.init(name: "BuySell", bundle: nil)
                
            
                
                if let buyStep4VC = buyStoryBoard.instantiateViewController(withIdentifier: "BuySellStep2") as? BuySellStep2ViewController
                {
                    
                    let dict = ["UnitsValue":unitsValue.text,
                                "UnitsAmount":unitsAmount.text,
                                "UnitsCurrency":unitsCurrency.text,
                                "PriceValue" : priceValue.text,
                                "PriceAmount": priceAmount.text,
                                "PriceCurrency": priceCurrency.text,
                                "TotalCurrency": totalCurrency.text,
                                "TotalValue": totalValue.text,
                                "TotalAmount": totalAmount.text,
                                "BuyWithCurrency": buyWithCurrencyLbl.text,
                                "BuywithValue": buyWithValue.text
                    ]
                    
                    //self.navigationController?.pushViewController(buyStep4VC, animated: true)
                    
                    buyStep4VC.dict = dict as? [String : String]
                    
                    if let firstAssetModel = getCurrentWalletAsset(), let secondAssetModel = assetModel.value {
                        
                        if let assetPairModel = getCurrentPairAsset(firstAssetModel, secondAsset: secondAssetModel)
                        {
                            self.showLoadingView(isLoading: true)
                            //Buying with eth
                            if firstAssetModel.blockchainType != BLOCKCHAIN_TYPE_ETHEREUM && secondAssetModel.blockchainType != BLOCKCHAIN_TYPE_ETHEREUM {
                                
                                let offchainTransactionManager = LWOffchainTransactionsManager.shared()
                                //offchainTransactionManager?.sendSwapRequest(forAsset: firstAssetModel.identity, pair: assetPairModel.identity, volume: unitsAmaountValue, completion: {
                                offchainTransactionManager?.sendSwapRequest(forAsset: self.firstWallet.identity, pair: assetPairModel.identity, volume: unitsAmaountValue, completion: {
                                    [weak self] result in
                                    self?.showLoadingView(isLoading: false)
                                    if result == nil {
                                        //self?.view.makeToast("There was problem with buying!")
                                        print("Error buying!")
                                        let alertController = UIAlertController(title: Localize("utils.error"), message: "Error buying!", preferredStyle: UIAlertControllerStyle.alert)
                                        let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
                                            (result : UIAlertAction) -> Void in
                                            print("OK")
                                        }
                                        
                                        alertController.addAction(okAction)
                                        self?.present(alertController, animated: true, completion: nil)
                                    }else {
                                        self?.navigationController?.pushViewController(buyStep4VC, animated: true)
                                    }
                                })
                            }
                            else {
                                //Buying with other currencies
                                let volumeNumber = NSNumber.init(value: unitsAmaountValue)
                                let transManager = LWEthereumTransactionsManager.shared()
                                //transManager?.requestTrade(forBaseAsset: assetModel.value, pair: assetPairModel, addressTo: "", volume: volumeNumber, completion: {[weak self] result in
                                transManager?.requestTrade(forBaseAsset: assetModel.value, pair: assetPairModel, addressTo: "", volume: volumeNumber, completion: {[weak self] result in
                                    self?.showLoadingView(isLoading: false)
                                    self?.navigationController?.pushViewController(buyStep4VC, animated: true)
                                })
                            }
                            
                        }
                        
                    }
                }
            }
        }
 
    }
    
    func getCurrentWalletAsset()->LWAssetModel? {
        for wallet in wallets.value {
            if wallet.identity == buyWithCurrencyLbl.text  {
                return wallet.asset
            }
        }
        
        return nil
    }
    
    func getCurrentPairAsset(_ firstAsset: LWAssetModel, secondAsset: LWAssetModel)->LWAssetPairModel? {
        if let cache = LWCache.instance() {
            for assetPair in cache.allAssetPairs {
                if let assetPairModelTmp = assetPair as? LWAssetPairModel {
                    print(assetPairModelTmp.baseAssetId, assetPairModelTmp.quotingAssetId)
                    if (assetPairModelTmp.baseAssetId == firstAsset.identity && assetPairModelTmp.quotingAssetId == secondAsset.identity) || (assetPairModelTmp.baseAssetId == secondAsset.identity && assetPairModelTmp.quotingAssetId == firstAsset.identity) {
                        return assetPairModelTmp
                    }
                }
            }
        }
        return nil
    }
}
