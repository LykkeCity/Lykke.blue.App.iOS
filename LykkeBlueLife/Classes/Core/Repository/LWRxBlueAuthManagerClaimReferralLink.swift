//
//  LWRxBlueAuthManagerClaimReferralLink.swift
//  WalletCore
//
//  Created by Vasil Garov on 12/6/17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import WalletCore

public class LWRxBlueAuthManagerClaimReferralLink: NSObject {
    
    public typealias Packet = ReferralLinkClaimPacket
    public typealias Result = ApiResult<Void>
    public typealias ResultType = Void
    public typealias RequestParams = ReferralLinkClaimPacket.Body
    
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


extension LWRxBlueAuthManagerClaimReferralLink: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: ReferralLinkClaimPacket.Body) -> ReferralLinkClaimPacket {
        return Packet(body: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        return Result.success(withData: Void())
    }
}
