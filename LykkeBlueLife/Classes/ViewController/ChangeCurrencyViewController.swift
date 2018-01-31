//
//  ChangeCurrencyViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/28/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class ChangeCurrencyViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource  {

    private var dataArray: NSArray = []
    @IBOutlet weak var currencyTable: UITableView!
    var triggerButton: UIButton = UIButton(type: UIButtonType.custom)
    
    var selectedCurrency = ""
    
    lazy var viewModel : BaseAssetSetViewModel={
        return BaseAssetSetViewModel(submit: self.triggerButton.rx.tap.asObservable())
    }()
    
    var disposeBag = DisposeBag()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // self.currencyTable.register(ChooseCurrencyViewCell.self, forCellReuseIdentifier: "ChooseCurrencyViewCell")
        currencyTable.register(UINib(nibName: "ChooseCurrencyViewCell", bundle: nil), forCellReuseIdentifier: "ChooseCurrencyViewCell")
        
        if(LWCache.instance().allAssets != nil)
        {
            dataArray = LWCache.instance().allAssets as NSArray
        }
        
        viewModel.loading.subscribe(onNext: {isLoading in
            self.showLoadingView(isLoading: isLoading)
        }).disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterError()
            .subscribe(onNext: {errorData in
                UIHelper.showErrorMessage(messageDict: errorData, forViewController: self)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.result.asObservable()
            .filterSuccess()
            .subscribe(onNext: {pack in
            LWCache.instance().baseAssetId = pack.identity
               self.goBack()
                
            })
            .disposed(by: disposeBag)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // print("Num: \(indexPath.row)")
        //print("Value: \(myArray[indexPath.row])")
        let model : LWAssetModel = dataArray.object(at: indexPath.row) as! LWAssetModel
        if(self.selectedCurrency == model.identity)
        {
            self.goBack()
            
        }
        else{
            //self.selectedCurrency = model.identity
            //LWCache.instance().baseAssetId  = model.identity
            self.viewModel.identity.value = model.identity
            self.triggerButton.sendActions(for: .touchUpInside)
        }
        currencyTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : ChooseCurrencyViewCell = tableView.dequeueReusableCell(withIdentifier: "ChooseCurrencyViewCell", for: indexPath as IndexPath) as! ChooseCurrencyViewCell
        
        
        let model : LWAssetModel = dataArray.object(at: indexPath.row) as! LWAssetModel
        let identityId = model.identity as String!
        cell.lblCurrency.text = identityId
        if(self.selectedCurrency == identityId)
        {
            cell.setActive(active: true)
        }
        else{
            cell.setActive(active: false)
        }
      //  cell.textLabel!.text = "\(myArray[indexPath.row])"
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }

    override func goBack() {
        //save
        var t = ""
        super.goBack()
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
