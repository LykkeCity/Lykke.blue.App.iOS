//
//  TradeCryptoViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 22.01.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore
import Toast

enum TradeType {
    case buy, sell
    
    var isBuy: Bool {
        return self == .buy
    }
    
    var isSell: Bool {
        return self == .sell
    }
}

class TradeCryptoViewController: BaseViewController {

    //MARK: - IB Outlets
    @IBOutlet weak var firstAsset: TradingAssetView!
    @IBOutlet weak var secondAsset: TradingAssetView!
    @IBOutlet weak var executeTradeButton: UIButton!
    
    //MARK: - Properties
    public var tradeType: TradeType!
    public var tradeAssetIdentifier: String?
    
    var confirmTrading = PublishSubject<Void>()
    fileprivate let disposeBag = DisposeBag()
    
    //MARK: - ViewModels
    lazy var buyOptimizedViewModel: BuyOptimizedViewModel = {
        return BuyOptimizedViewModel(trigger: self.confirmTrading,
                                     dependency: (currencyExchanger: CurrencyExchanger(),
                                                  authManager: LWRxAuthManager.instance,
                                                  spreadService: SpreadService()))
    }()
    
    lazy var tradingAssetsViewModel: TradingAssetsViewModel = {
        return TradingAssetsViewModel()
    }()
    
    lazy var payWithAssetListViewModel: PayWithAssetListViewModel = {
        return PayWithAssetListViewModel(buyAsset: self.buyOptimizedViewModel.buyAsset.asObservable().mapToAsset())
    }()
    
    lazy var buyWithAssetListViewModel: BuyWithAssetListViewModel = {
        return BuyWithAssetListViewModel(sellAsset: self.buyOptimizedViewModel.payWithWallet.asObservable().mapToAsset())
    }()
    
    var loadingViewModel: LoadingViewModel!
    
    //MARK: - Computed properties
    var walletListView: TradingAssetView {
        return tradeType.isBuy ? secondAsset : firstAsset
    }
    
    var assetListView: TradingAssetView {
        return tradeType.isBuy ? firstAsset : secondAsset
    }
    
    var walletList: Observable<[LWSpotWallet]> {
        return tradeType.isBuy ? payWithAssetListViewModel.payWithWalletList : tradingAssetsViewModel.availableToSell
    }
    
    var assetList: Observable<[LWAssetModel]> {
        return tradeType.isBuy ? tradingAssetsViewModel.availableToBuy : buyWithAssetListViewModel.buyWithAssetList
    }
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: caller should set these properties
        // For now the default behavior is to buy TREE
        tradeType = TradeType.buy
        tradeAssetIdentifier = "TREE"
        
        setupFormUX(disposedBy: disposeBag)
        firstAsset.setupUX(width: view.frame.width, disposedBy: disposeBag)
        secondAsset.setupUX(width: view.frame.width, disposedBy: disposeBag)
        
        //???: what does bid mean?
        buyOptimizedViewModel.bid.value = tradeType.isSell
        
        
        buyOptimizedViewModel.bindBuy(toView: assetListView, disposedBy: disposeBag)
        buyOptimizedViewModel.bindPayWith(toView: walletListView, disposedBy: disposeBag)
        buyOptimizedViewModel.bind(toViewController: self).disposed(by: disposeBag)
        
        walletListView.itemPicker.picker.rx.itemSelected
            .withLatestFrom(walletList) { selected, wallets in
                wallets.enumerated().first { $0.offset == selected.row }?.element
            }
            .filterNil()
            .map { (autoUpdated: false, wallet: $0) }
            .bind(to: buyOptimizedViewModel.payWithWallet)
            .disposed(by: disposeBag)
        
        walletList
            .map { $0.first }
            .filterNil()
            .map { (autoUpdated: true, wallet: $0) }
            .bind(to: buyOptimizedViewModel.payWithWallet)
            .disposed(by: disposeBag)
        
        walletList
            .bind(to: walletListView.itemPicker.picker.rx.itemAttributedTitles) { (_, wallet) in return NSAttributedString(string: wallet.asset.displayId, attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)]) }
            .disposed(by: disposeBag)
        
        assetListView.itemPicker.picker.rx.itemSelected
            .withLatestFrom(assetList) { selected, assets in
                assets.enumerated().first { $0.offset == selected.row }?.element
            }
            .filterNil()
            .map { (autoUpdated: false, asset: $0) }
            .bind(to: buyOptimizedViewModel.buyAsset)
            .disposed(by: disposeBag)
        
        assetList
            .map { $0.first }
            .filterNil()
            .map { (autoUpdated: true, asset: $0) }
            .bind(to: buyOptimizedViewModel.buyAsset)
            .disposed(by: disposeBag)
        
        assetList
            .bind(to: assetListView.itemPicker.picker.rx.itemAttributedTitles) { (_, asset) in
                return NSAttributedString(string: asset.displayId, attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
            }
            .disposed(by: disposeBag)

        // TODO: show PIN vc
//        executeTradeButton.rx.tap
//            .flatMap {
//                return PinViewController.presentOrderPinViewController(from: self, title: Localize("newDesign.enterPin"),
//                                                                       isTouchIdEnabled: true)
//            }
//            .bind(to: confirmTrading)
//            .disposed(by: disposeBag)
        
        executeTradeButton.rx.tap
            .bind(to: confirmTrading)
            .disposed(by: disposeBag)

        
        let assetPairObservable = confirmTrading.asObserver()
            .map { [buyOptimizedViewModel] _ in (buyOptimizedViewModel.mainAsset, buyOptimizedViewModel.quotingAsset) }
            .filter { $0.0 != nil && $0.1 != nil }
            .flatMap { LWRxAuthManager.instance.assetPairs.request(baseAsset: $0.0!, quotingAsset: $0.1!) }
            .shareReplay(1)
        
        assetPairObservable
            .filter { $0.getError() != nil }
            .map { _ -> [AnyHashable: Any] in ["Message": "Unable to take asset pair"] }
            .asDriver(onErrorJustReturn: [:])
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        let tradingObservable = assetPairObservable.filterSuccess()
            .filterNil()
            .flatMap { [buyOptimizedViewModel] assetPair -> Observable<ApiResult<LWAssetDealModel?>> in
                guard let asset = buyOptimizedViewModel.mainAsset, let isSell = buyOptimizedViewModel.bid.value, let amount = buyOptimizedViewModel.tradeAmount else {
                    return Observable.empty()
                }
                return LWMarketOrdersManager.createOrder(assetPair: assetPair, assetId: asset.identity, isSell: isSell, volume: String(describing: amount))
            }
            .shareReplay(1)
        
        tradingObservable
            .map { $0.getSuccess() }
            .filterNil()
            .map { $0 != nil }
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: {[weak self] success in
                guard success else { return }
                guard let vc = self else { return }
                vc.buyOptimizedViewModel.buyAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "")
                vc.buyOptimizedViewModel.payWithAmount.value = BuyOptimizedViewModel.Amount(autoUpdated: true, value: "")
                vc.view.makeToast("Your exchange has been successfuly processed. It will appear in your transaction history soon.")
            })
            .disposed(by: disposeBag)
        
        loadingViewModel = LoadingViewModel([
            tradingAssetsViewModel.loadingViewModel.isLoading,
            payWithAssetListViewModel.loadingViewModel.isLoading,
            assetPairObservable.isLoading(),
            tradingObservable.isLoading()
            ])
        
        loadingViewModel.isLoading
            .bind(to: rx.loading)
            .disposed(by: disposeBag)
        
        if let assetIdentifier = tradeAssetIdentifier {
            if tradeType.isBuy {
                assetList
                    .take(1)
                    .map { $0.filter { asset in return asset.identity == assetIdentifier }.first }
                    .filterNil()
                    .map{(autoUpdated: true, asset: $0)}
                    .bind(to: buyOptimizedViewModel.buyAsset)
                    .disposed(by: disposeBag)
            }
            else {
                walletList
                    .take(1)
                    .map { $0.filter { wallet in return wallet.asset.identity == assetIdentifier }.first }
                    .filterNil()
                    .map { (autoUpdated: true, wallet: $0) }
                    .bind(to: buyOptimizedViewModel.payWithWallet)
                    .disposed(by: disposeBag)
            }
        }
    }
}

extension TradeCryptoViewController: InputForm {
    
    var textFields: [UITextField] {
        return [
            firstAsset.amount,
            secondAsset.amount
        ]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
    
    var submitButton: UIButton {
        return executeTradeButton
    }
}

fileprivate extension BuyOptimizedViewModel {
    
    func bindBuy(toView view: TradingAssetView, disposedBy disposeBag: DisposeBag) {
        
        baseAssetCode
            .drive(view.baseAssetCode.rx.text)
            .disposed(by: disposeBag)
        
        buyAssetIconURL
            .filterNil()
            .drive(view.assetIcon)
            .disposed(by: disposeBag)
        
        buyAmountInBase
            .drive(view.amountInBase.rx.text)
            .disposed(by: disposeBag)
        
        buyAssetCode
            .drive(view.assetCode.rx.text)
            .disposed(by: disposeBag)
        
        (view.amount.rx.textInput <-> buyAmount)
            .disposed(by: disposeBag)
        
        buyAssetName
            .drive(view.assetName.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindPayWith(toView view: TradingAssetView, disposedBy disposeBag: DisposeBag) {
        
        baseAssetCode
            .drive(view.baseAssetCode.rx.text)
            .disposed(by: disposeBag)
        
        payWithAssetIconURL
            .filterNil()
            .drive(view.assetIcon)
            .disposed(by: disposeBag)
        
        payWithAmountInBase
            .drive(view.amountInBase.rx.text)
            .disposed(by: disposeBag)
        
        payWithAssetCode
            .drive(view.assetCode.rx.text)
            .disposed(by: disposeBag)
        
        (view.amount.rx.textInput <-> payWithAmount)
            .disposed(by: disposeBag)
        
        payWithAssetName
            .drive(view.assetName.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bind(toViewController vc: TradeCryptoViewController) -> [Disposable] {
        
        let bidDriver = bid.asDriver().filterNil()
        
        return [
        isValidPayWithAmount
            .filterError()
            .map { $0["Message"] as? String }
            .filterNil()
            .subscribe(onNext: { [weak vc] (message) in
                vc?.view.makeToast(message, duration: 2.0, position: CSToastPositionTop)
            }),
        isValidPayWithAmount
            .map { $0.isSuccess }
            .bind(to: vc.submitButton.rx.isEnabled),
        
        // TODO: add UI elements for these drivers
//        spreadPercent.drive()
//        spreadAmount.drive()
        bidDriver.map { $0 ? "SELL" : "PAY WITH" }.drive(vc.walletListView.title.rx.text),
        bidDriver.map { $0 ? "RECEIVE" : "BUY" }.drive(vc.assetListView.title.rx.text),
        bidDriver.map { $0 ? "SELL": "BUY" }.drive(onNext:{ vc.submitButton.setTitle($0, for: .normal)})
        ]
    }
}

extension Observable where Element == ApiResult<LWAssetDealModel?> {
    
    func isLoading() -> Observable<Bool> {
        return
            map { result -> Bool in
                if case .loading = result { return true }
                else { return false }
        }
    }
    
}
