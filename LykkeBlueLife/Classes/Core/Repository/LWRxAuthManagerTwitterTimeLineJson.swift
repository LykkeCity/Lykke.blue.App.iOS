//
//  LWRxAuthManagerTwitterTimeLineJson.swift
//  WalletCore
//
//  Created by Georgi Stanev on 28.11.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import Foundation
import RxSwift
import WalletCore

public class LWRxAuthManagerTwitterTimeLineJson: NSObject {
    
    public typealias Packet = TwitterTimeLineJsonPacket
    public typealias Result = ApiResultList<[AnyHashable: Any]>
    public typealias RequestParams = TwitterTimeLineJsonPacket.Body
    
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


extension LWRxAuthManagerTwitterTimeLineJson: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: TwitterTimeLineJsonPacket.Body) -> TwitterTimeLineJsonPacket {
        return Packet(body: params, observer: observer)
    }
    
    public func getSuccessResult(fromPacket packet: TwitterTimeLineJsonPacket) -> Result {
        return Result.success(withData: packet.model)
    }
}

public extension ObservableType where Self.E == ApiResultList<[AnyHashable: Any]> {
    public func filterSuccess() -> Observable<[[AnyHashable: Any]]> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
