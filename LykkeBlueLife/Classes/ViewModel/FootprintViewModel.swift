//
//  FootprintViewModel.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/8/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

fileprivate enum SliderValues {
    static let min: Float = 5.0
    static let max: Float = 80.0
    static let step: Float = 20.0
}

fileprivate enum Predefined {
    static let captions = [5: "An average Thai's emissions for one year",
                           20: "An average American's emissions for one year",
                           40: "You like to travel and take 2-3 long flights per year",
                           60: "You travel weekly for business plus take 2-3 long flights per year",
                           80: "Stewardesses know you by name. You live on an airplane"]
}

struct FootprintViewModel {

    let footprint: Driver<String>
    let caption: Driver<String>
    let hidesCurrent: Driver<Bool>
    
    let minText = "\(Int(SliderValues.min))t"
    let maxText = "\(Int(SliderValues.max))t"
    
    let minValue = SliderValues.min
    let maxValue = SliderValues.max
    let step = SliderValues.step
    
    init(value: Observable<Float>) {
        let value = value.startWith(minValue)
        
        footprint = value
            .map{ "\(Int($0))t" }
            .asDriver(onErrorJustReturn: "")
        
        caption = value
            .map{ Predefined.captions[Int($0)] ?? "" }
            .asDriver(onErrorJustReturn: "")
        
        hidesCurrent = value
            .debug("hides current before map ->", trimOutput: false)
            .map{ $0 == SliderValues.min || $0 == SliderValues.max }
            .asDriver(onErrorJustReturn: true)
            .distinctUntilChanged()
    }
    
}
