//
//  SignUpGeneratePrivateKeyViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 23.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

class SignUpGeneratePrivateKeyViewController: UIViewController {

    @IBOutlet var swipe: UISwipeGestureRecognizer!
    @IBOutlet weak var image: UIImageView!
    
    private let currentSwipeCount = Variable<Int>(0)
    private static let targetSwipeCount = 4
    
    private let disposeBag = DisposeBag()
    
    lazy var viewModel : ClientKeysViewModel = {
        return ClientKeysViewModel(submit: self.viewModelTrigger.asObservable().filterNil())
    }()
    
    private let viewModelTrigger = Variable<Void?>(nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        swipe.rx.event.asObservable()
            .map{ [currentSwipeCount] _  in currentSwipeCount.value + 1 }
            .filter{ $0 <= SignUpGeneratePrivateKeyViewController.targetSwipeCount }
            .bind(to: currentSwipeCount)
            .disposed(by: disposeBag)
        
        currentSwipeCount.asObservable()
            .mapToImage()
            .bind(to: image.rx.image)
            .disposed(by: disposeBag)
        
        currentSwipeCount.asObservable()
            .filter{ $0 == SignUpGeneratePrivateKeyViewController.targetSwipeCount }
            .map{ _ in Void() }
            .do(onNext: { [viewModel] _ in
                LWPrivateKeyManager.shared().savePrivateKeyLykke(fromSeedWords: LWPrivateKeyManager.generateSeedWords12())
                viewModel.pubKey.value = LWPrivateKeyManager.shared().publicKeyLykke
                viewModel.encodedPrivateKey.value = LWPrivateKeyManager.shared().encryptedKeyLykke
            })
            .bind(to: viewModelTrigger)
            .disposed(by: disposeBag)
        
        viewModel
            .bind(toViewController: self)
            .disposed(by: disposeBag)
    
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

fileprivate extension ClientKeysViewModel {
    func bind(toViewController vc: SignUpGeneratePrivateKeyViewController) -> [Disposable] {
        return [
            loading.bind(to: vc.rx.loading),
            result.asObservable().filterError().bind(to: vc.rx.error),
            result.asObservable().filterSuccess().subscribe(onNext: { [weak vc] _ in
                vc?.rx.hideLoading()
                //vc?.dismiss(animated: false)
                AppCoordinator.shared.showHome(fromViewController: vc)
            })
        ]
    }
}

fileprivate extension ObservableType where Self.E == Int {
    func mapToImage() -> Observable<UIImage> {
        return map{
            switch $0 {
            case 0: return #imageLiteral(resourceName: "WalletGenerateKeyStep1")
            case 1: return #imageLiteral(resourceName: "WalletGenerateKeyStep2")
            case 2: return #imageLiteral(resourceName: "WalletGenerateKeyStep3")
            case 3: return #imageLiteral(resourceName: "WalletGenerateKeyStep4")
            case 4: return #imageLiteral(resourceName: "WalletGenerateKeyStep5")
            default: return #imageLiteral(resourceName: "WalletGenerateKeyStep1")
            }
        }
    }
}
