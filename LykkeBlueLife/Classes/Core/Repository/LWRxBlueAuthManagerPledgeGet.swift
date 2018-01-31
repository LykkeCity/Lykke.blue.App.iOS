//
//  LWRxBlueAuthManagerPledgeGet.swift
//  WalletCore
//
//  Created by Vasil Garov on 11/29/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import WalletCore

public class LWRxBlueAuthManagerPledgeGet: NSObject {
    
    public typealias Packet = PledgeGetPacket
    public typealias Result = ApiResult<PledgeModel>
    public typealias ResultType = PledgeModel
    public typealias RequestParams = Void
    
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


extension LWRxBlueAuthManagerPledgeGet: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: Void) -> LWRxBlueAuthManagerPledgeGet.Packet {
        return Packet(observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        guard let model = packet.model else {
            return Result.error(withData: ["Message":"Couldn't retreive pledges."])
        }
        
        return Result.success(withData: model)
    }
}

public extension ObservableType where Self.E == ApiResult<PledgeModel> {
    public func filterSuccess() -> Observable<PledgeModel> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
