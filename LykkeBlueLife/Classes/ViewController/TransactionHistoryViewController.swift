//
//  TransactionHistoryViewController.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 9/26/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import WalletCore

class TransactionHistoryViewController: BaseViewController {

   
    var downloadCSV: UIButton = UIButton(type: UIButtonType.custom)
    @IBOutlet weak var transactionsTableView: UITableView!
    
    let disposeBag = DisposeBag()
    lazy var transactionsViewModel:TransactionsViewModel = {
        return TransactionsViewModel(
            downloadCsv: self.downloadCSV.rx.tap.asObservable(),
            dependency: (
                currencyExcancher: CurrencyExchanger(),
                authManager: LWRxAuthManager.instance,
                formatter: TransactionFormatter.instance
            )
        )
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        

        
        transactionsTableView.register(UINib(nibName: "LWPortfolioCurrencyTableViewCell", bundle: nil), forCellReuseIdentifier: "LWPortfolioCurrencyTableViewCell")
        
        transactionsViewModel.transactions.asObservable()
            .bind(
                to: transactionsTableView.rx.items(cellIdentifier: "LWPortfolioCurrencyTableViewCell",
                                                   cellType: LWPortfolioCurrencyTableViewCell.self)
            ){ (row, element, cell) in
                cell.bind(toTransaction: element)
            }
            .disposed(by: disposeBag)
        
        transactionsViewModel.loading.isLoading
            .subscribe(onNext: {[weak self] in
                self?.showLoadingView(isLoading: $0)
            })
            .disposed(by: disposeBag)
        
        transactionsViewModel.transactionsAsCsv
            .isLoading()
            .drive(onNext: {[weak self] isLoading in
                self?.showLoadingView(isLoading: isLoading)
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUserInterface() {
       // self.navigationController?.setNavigationBarHidden(false, animated: false)
      //  self.navigationController?.navigationItem.hidesBackButton = false
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
