//
//  BuySellStep2ViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 9/11/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore

class BuySellStep2ViewController: BaseViewController {
    
    @IBOutlet weak var buyWithCurrencyLbl: UILabel!
    @IBOutlet weak var unitsValue: UILabel!
    @IBOutlet weak var unitsTitle: UILabel!
    @IBOutlet weak var unitsCurrency: UILabel!
    @IBOutlet weak var unitsAmount : UILabel!
    @IBOutlet weak var priceCurrency: UILabel!
    @IBOutlet weak var totalCurrency: UILabel!
    @IBOutlet weak var totalValue: UILabel!
    @IBOutlet weak var buyWithValue: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var priceValue: UILabel!
    @IBOutlet weak var priceAmount: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    var dict: [String:String]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        imageHeight.constant =  Display.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dict != nil {
            self.unitsAmount.text = dict?["UnitsAmount"]
            self.unitsValue.text = dict?["UnitsValue"]
            unitsCurrency.text = dict?["UnitsCurrency"]
            priceValue.text = dict?["PriceValue"]
            priceAmount.text = dict?["PriceAmount"]
            priceCurrency.text = dict?["PriceCurrency"]
            totalCurrency.text = dict?["TotalCurrency"]
            totalValue.text = dict?["TotalValue"]
            totalAmount.text = dict?["TotalAmount"]
            buyWithCurrencyLbl.text = dict?["BuyWithCurrency"]
            buyWithValue.text = dict?["BuywithValue"]
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func portfolioAction(_ sender: UIButton) {
        self.dismiss(animated: true)
        
        
        
        /*
        if let unitsAmaountValue = Double(unitsAmount.text!) {
            
            if unitsAmount.text != "" && buyWithCurrencyLbl.text != "" && unitsAmaountValue>0{
                
                let buyStoryBoard = UIStoryboard.init(name: "Buy", bundle: nil)
                
                if let buyStep4VC = buyStoryBoard.instantiateViewController(withIdentifier: "BuyStep4") as? LWBuyStep4ViewController
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
                    buyStep4VC.dict = dict as? [String : String]
                    
                    if let firstAssetModel = getCurrentWalletAsset(), let secondAssetModel = assetModel.value {
                        
                        if let assetPairModel = getCurrentPairAsset(firstAssetModel, secondAsset: secondAssetModel)
                        {
                            self.setLoading(true)
                            //Buying with eth
                            if firstAssetModel.blockchainType != BLOCKCHAIN_TYPE_ETHEREUM && secondAssetModel.blockchainType != BLOCKCHAIN_TYPE_ETHEREUM {
                                
                                let offchainTransactionManager = LWOffchainTransactionsManager.shared()
                                offchainTransactionManager?.sendSwapRequest(forAsset: firstAssetModel.identity, pair: assetPairModel.identity, volume: unitsAmaountValue, completion: {
                                    [weak self] result in
                                    self?.setLoading(false)
                                    if result == nil {
                                        self?.view.makeToast("There was problem with buying!")
                                    }else {
                                        self?.navigationController?.pushViewController(buyStep4VC, animated: true)
                                    }
                                })
                            }
                            else {
                                //Buying with other currencies
                                let volumeNumber = NSNumber.init(value: unitsAmaountValue)
                                let transManager = LWEthereumTransactionsManager.shared()
                                transManager?.requestTrade(forBaseAsset: assetModel.value, pair: assetPairModel, addressTo: "", volume: volumeNumber, completion: {[weak self] result in
                                    self?.setLoading(false)
                                    self?.navigationController?.pushViewController(buyStep4VC, animated: true)
                                })
                            }
                            
                        }
                        
                    }
                }
            }
        }
        */
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
