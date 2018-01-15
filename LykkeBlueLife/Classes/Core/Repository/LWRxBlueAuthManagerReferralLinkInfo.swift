//
//  LWRxBlueAuthManagerReferralLinkInfo.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/5/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import WalletCore

public class LWRxBlueAuthManagerReferralLinkInfo: NSObject {
    
    public typealias Packet = ReferralLinkInfoPacket
    public typealias Result = ApiResult<ReferralLinkInfoModel>
    public typealias ResultType = ReferralLinkInfoModel
    public typealias RequestParams = String
    
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


extension LWRxBlueAuthManagerReferralLinkInfo: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: String) -> LWRxBlueAuthManagerReferralLinkInfo.Packet {
        return Packet(id: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        guard let model = packet.model else {
            return Result.error(withData: ["Message":"Couldn't retreive referral link info."])
        }
        
        return Result.success(withData: model)
    }
}

public extension ObservableType where Self.E == ApiResult<ReferralLinkInfoModel> {
    public func filterSuccess() -> Observable<ReferralLinkInfoModel> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}

