//
//  FootprintViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/3/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import WalletCore

class FootprintViewController: UIViewController {
    
    @IBOutlet weak var footprintValue: UILabel!
    @IBOutlet weak var footprintSlider: UISlider!
    @IBOutlet weak var footprintCaption: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var currentLeft: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    lazy var viewModel: FootprintViewModel = {
        return FootprintViewModel(value: self.footprintSlider.rx.value.asObservable().skip(1))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupUI()
    }
    
    private func setupViewModel() {
        viewModel
            .bind(to: self)
            .disposed(by: disposeBag)
    }
    
    private func setupUI() {
        minLabel.text = viewModel.minText
        maxLabel.text = viewModel.maxText
        footprintSlider.minimumValue = viewModel.minValue
        footprintSlider.maximumValue = viewModel.maxValue
        footprintSlider.value = viewModel.minValue
    }
    
    @IBAction func sliderChanged(_ slider: UISlider) {
        updateUI(forSlider: slider)
    }
    
    @IBAction func next(_ sender: Any) {
        saveSelection()
    }
    
    private func saveSelection() {
        UserDefaults.standard.set(Int(footprintSlider.value), forKey: UserDefaultsKeys.footprintValue)
        UserDefaults.standard.synchronize()
    }
    
    private func updateUI(forSlider slider: UISlider) {
        let roundedValue = round(slider.value / viewModel.step) * viewModel.step
        slider.value = roundedValue
        currentLeft.constant = footprintSlider.thumbCenterX - current.bounds.size.width / 2
    }
}

fileprivate extension FootprintViewModel {
    func bind(to vc: FootprintViewController) -> [Disposable] {
        return [
            caption.drive(vc.footprintCaption.rx.text),
            footprint.drive(vc.footprintValue.rx.text),
            footprint.drive(vc.current.rx.text),
            hidesCurrent.drive(vc.current.rx.isHidden)
        ]
    }
}
