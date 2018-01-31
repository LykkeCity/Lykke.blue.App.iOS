//
//  ReceiveByWAddressViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 9/20/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import WalletCore

class ReceiveByWAddressViewController: BaseViewController,LWAuthManagerDelegate {
    
    var wallet : LWSpotWallet = LWSpotWallet()
  
    @IBOutlet weak var walletAddress: UILabel!
    @IBOutlet weak var qrCodeImage: UIImageView!
    
    let authManager: LWRxAuthManager = LWRxAuthManager.instance
    let assetModel = Variable<LWAssetModel?>(nil)
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        LWAuthManager.instance().delegate = self //as LWAuthManagerDelegate
      
        
        authManager.allAssets.request(byId: self.wallet.identity)
            .filterSuccess()
            .filterNil()
            .bind(to: assetModel)
            .disposed(by: disposeBag)
        
        assetModel.asObservable().subscribe(onNext: {[weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.walletAddress.text = strongSelf.assetModel.value?.blockchainDepositAddress
            strongSelf.qrCodeImage.image = strongSelf.generateQRCode(from: strongSelf.walletAddress.text ?? "")
        }).disposed(by: disposeBag)
    }

    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func copyToClipboard(_ sender: UIButton) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = self.walletAddress.text

    }
    
    @IBAction func setdToEmail(_ sender: UIButton) {
        self.showLoadingView(isLoading: true)
        LWAuthManager.instance().caller=self
        if(self.wallet.identity == "SLR")
        {
            LWAuthManager.instance().requestEmailBlockchain(forAssetId: self.wallet.identity, address: "")
        }
        else{
            LWAuthManager.instance().requestEmailBlockchain(forAssetId: self.wallet.identity, address: self.walletAddress.text)
        }
    }
    
    func authManager(_ manager: LWAuthManager!, didFailWithReject reject: [AnyHashable : Any]!, context: GDXRESTContext!) {
        self.showLoadingView(isLoading: false)
        let alertController = UIAlertController(title: Localize("utils.error"), message: "Error sending email", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    func authManagerDidSendBlockchainEmail(_ manager: LWAuthManager!) {
        self.showLoadingView(isLoading: false)
        let alertController = UIAlertController(title: nil, message: "Email sent", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func authManagerDidSendSolarCoinEmail(_ manager: LWAuthManager!) {
        self.showLoadingView(isLoading: false)
        let alertController = UIAlertController(title: nil, message: "Email sent", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: Localize("utils.ok"), style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 4, y: 4)
            
            if let output = filter.outputImage?.applying(transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    func generateQRCodeImage(walletAddress: String)->(UIImage){
        let data = walletAddress.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")
        
        filter?.setValue(data, forKey: "inputMessage")
        
        
        let qrcodeImage = filter?.outputImage
        let result = self.convert(cmage: qrcodeImage!)
        return result
    }

    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
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
