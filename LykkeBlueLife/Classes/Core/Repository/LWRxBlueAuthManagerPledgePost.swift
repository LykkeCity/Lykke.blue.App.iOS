//
//  LWRxBlueAuthManagerPledgePost.swift
//  WalletCore
//
//  Created by Vasil Garov on 11/28/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import WalletCore

public class LWRxBlueAuthManagerPledgePost: NSObject {
    
    public typealias Packet = PledgePostPacket
    public typealias Result = ApiResult<Void>
    public typealias ResultType = Void
    public typealias RequestParams = PledgePostPacket.Body
    
    override init() {
        super.init()
        subscribe(observer: self, succcess: #selector(self.successSelector(_:)), error: #selector(self.errorSelector(_:)))
    }
    
    deinit {
        unsubscribe(observer: self)
    }
    
    @objc func successSelector(_ notification: NSNotification) {
        onSuccess(notification)
    }
    
    @objc func errorSelector(_ notification: NSNotification) {
        onError(notification)
    }
}


extension LWRxBlueAuthManagerPledgePost: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: PledgePostPacket.Body) -> PledgePostPacket {
        return Packet(body: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: Void())
    }
}
