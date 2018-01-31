//
//  NetPositiveViewModel.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/9/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

fileprivate enum SliderValues {
    static let min: Float = 1.0
    static let max: Float = 10.0
    static let preselected: Float = 3.0
}

fileprivate enum Predefined {
    static let caption = "One mangrove mitigates 25kg CO2/year. %d TREE will make you %d%% climate net positive."
}

struct NetPositiveViewModel {
    
    let netPositive: Driver<String>
    let caption: Driver<String>
    let hidesCurrent: Driver<Bool>
    
    let minText = "\(Int(SliderValues.min))x"
    let maxText = "\(Int(SliderValues.max))x"
    
    let minValue = SliderValues.min
    let maxValue = SliderValues.max
    let preselectedValue = SliderValues.preselected
    
    init(value: Observable<Float>) {
        let value = value.startWith(minValue)
        
        netPositive = value
            .map{ "\(Int($0))x" }
            .asDriver(onErrorJustReturn: "")
        
        caption = value
            .map{ String(format: Predefined.caption, Int($0) * 800, Int($0) * 100) }
            .asDriver(onErrorJustReturn: "")
        
        hidesCurrent = value
            .map{ $0 == SliderValues.min || $0 == SliderValues.max }
            .asDriver(onErrorJustReturn: true)
    }
}
