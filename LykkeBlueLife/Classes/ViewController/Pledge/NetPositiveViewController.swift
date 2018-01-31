//
//  NetPositiveViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/7/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class NetPositiveViewController: UIViewController {
    
    @IBOutlet weak var netPositiveValue: UILabel!
    @IBOutlet weak var netPositiveSlider: UISlider!
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var current: UILabel!
    @IBOutlet weak var currentLeft: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    
    lazy var viewModel: NetPositiveViewModel = {
       return NetPositiveViewModel(value: self.netPositiveSlider.rx.value.asObservable())
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
        netPositiveSlider.minimumValue = viewModel.minValue
        netPositiveSlider.maximumValue = viewModel.maxValue
        netPositiveSlider.value = viewModel.preselectedValue
        updateUI(forSlider: netPositiveSlider)
    }
    
    @IBAction func sliderChanged(_ slider: UISlider) {
        updateUI(forSlider: slider)
    }
    
    @IBAction func next(_ sender: Any) {
        saveSelection()
    }
    
    private func updateUI(forSlider slider: UISlider) {
        slider.value = roundf(slider.value)
        currentLeft.constant = netPositiveSlider.thumbCenterX - current.bounds.size.width / 2
    }
    
    private func saveSelection() {
        UserDefaults.standard.set(Int(netPositiveSlider.value), forKey: UserDefaultsKeys.netPositiveValue)
        UserDefaults.standard.synchronize()
    }
}

fileprivate extension NetPositiveViewModel {
    func bind(to vc: NetPositiveViewController) -> [Disposable] {
        return [
            caption.drive(vc.caption.rx.text),
            netPositive.drive(vc.netPositiveValue.rx.text),
            netPositive.drive(vc.current.rx.text),
            hidesCurrent.drive(vc.current.rx.isHidden)
        ]
    }
}
