//
//  TransferByWAddressViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 9/18/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore
import AVFoundation
import QRCodeReader

class TransferByWAddressViewController: BaseViewController {

    var wallet : LWSpotWallet = LWSpotWallet()
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var walletTextField: UITextField!
    
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObjectTypeQRCode], captureDevicePosition: .back)
            $0.showTorchButton = true
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func transferAction(_ sender: UIButton) {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        let amount = formatter.number(from: amountTextField.text!)
        self.showLoadingView(isLoading: true)
        let asset = LWCache.asset(byId: wallet.identity)

        if(asset?.blockchainType == BLOCKCHAIN_TYPE_ETHEREUM) {
            
            /*
            [[LWEthereumTransactionsManager shared] requestCashoutForAsset:asset volume:amount addressTo:self.bitcoinString completion:^(NSDictionary *result){
                [self setLoading:NO];
                
                BOOL success = [result isKindOfClass:[NSError class]] == NO;
                [self cashoutCompleteWithSuccess:success];
                }];
 */
            self.showLoadingView(isLoading: false)
            self.dismiss(animated: true)
        }
        //else if([LWCache instance].flagOffchainRequests == NO) {
        else if(LWCache.instance().flagOffchainRequests == false) {
            //LWCache.instance().calle
            
            //[LWAuthManager instance].caller = self;
            LWAuthManager.instance().caller = self
            
            LWAuthManager.instance().requestCashOut( amount, assetId: self.wallet.identity, multiSig: walletTextField.text!)
            /*
            [[LWAuthManager instance] requestCashOut:amount
                assetId:self.assetId
                multiSig:self.bitcoinString];*/
            self.showLoadingView(isLoading: false)
            self.dismiss(animated: true)
        }
        else {
            
            
            LWOffchainTransactionsManager.shared().requestCashOut(amount
                , assetId: self.wallet.identity, multiSig: walletTextField.text!, completion: { (result : [AnyHashable : Any]?) in
                self.showLoadingView(isLoading: false)
                    self.dismiss(animated: true)
            })
            /*
            [[LWOffchainTransactionsManager shared] requestCashOut:amount assetId:self.assetId multiSig:self.bitcoinString completion:^(NSDictionary *result) {
                [self setLoading:NO];
                
                BOOL success = result != nil && [result isKindOfClass:[NSError class]] == NO;
                [self cashoutCompleteWithSuccess:success];
                }];*/
        }

    }

    @IBAction func scan(_ sender: Any) {
        readerVC.modalPresentationStyle = .formSheet
        readerVC.delegate = self
        
        readerVC.completionBlock = {[weak self] (result: QRCodeReaderResult?) in
            if let result = result {
                self?.walletTextField.text = result.value
            }
        }
        
        present(readerVC, animated: true, completion: nil)
    }
}

// MARK: QRCodeReader Delegate methods

extension TransferByWAddressViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
}
