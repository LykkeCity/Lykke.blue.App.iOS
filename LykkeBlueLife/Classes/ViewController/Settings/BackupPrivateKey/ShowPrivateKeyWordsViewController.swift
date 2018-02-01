//
//  ShowPrivateKeyWordsViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 31.01.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class ShowPrivateKeyWordsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageLabel: UILabel!
    
    fileprivate let words = LWPrivateKeyManager.shared().generatePrivateKeyWords()
    fileprivate var currentWordIndex = 0
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let obs = Observable.just(words)
        obs.bind(to: self.collectionView.rx.items(cellIdentifier: "WordCell", cellType: UICollectionViewCell.self)) { [weak self] row, data, cell in
            
                guard let wordLabel = cell.contentView.subviews.first as? UILabel else {
                    return
                }
            
                wordLabel.text = self?.words[row]
            
            }.addDisposableTo(disposeBag)
        
        previousButton.rx.tap.asObservable()
        .subscribe(onNext: { [weak self] in
            guard var current = self?.currentWordIndex else {
                return
            }
            
            current = max(current - 1, 0)
            self?.scrollAtWordIndex(current)
        })
        .disposed(by: disposeBag)
        
        nextButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] in
                guard var current = self?.currentWordIndex else {
                    return
                }
                
                let maxIndex = (self?.words.count)! - 1
                guard current < maxIndex else {
                    self?.completedWordsWriting()
                    return
                }
                
                current += 1
                self?.scrollAtWordIndex(current)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        completedWordsWriting()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        layout.itemSize = collectionView.bounds.size
    }
    
    func scrollAtWordIndex(_ index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        previousButton.isEnabled = index != 0
        nextButton.isEnabled = index < words.count
        currentWordIndex = index
        pageLabel.text = "\(index + 1) of \(words.count)"
    }
    
    func completedWordsWriting() {
        performSegue(withIdentifier: "checkWordsBackup", sender: nil)
    }
    
    // MARK: - Navigation

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkWordsBackup" {
            let vc = segue.destination as! CheckPrivateKeyWordsViewController
            vc.words = words
        }
     }

}
