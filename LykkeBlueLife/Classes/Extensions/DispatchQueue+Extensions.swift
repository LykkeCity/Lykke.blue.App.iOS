//
//  DispatchQueue.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 26.01.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import Foundation

extension DispatchQueue {
    func asyncAfter(_ after: Double, execute work: @escaping @convention(block) () -> Swift.Void) {
        self.asyncAfter(deadline: dispatchDelay(after), execute: work)
    }
    
    func dispatchDelay(_ delay: Double) -> DispatchTime {
        let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        return time
    }
}
