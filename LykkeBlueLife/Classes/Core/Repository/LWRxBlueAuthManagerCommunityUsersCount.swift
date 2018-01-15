//
//  LWRxBlueAuthManagerCommunityUsersCount.swift
//  WalletCore
//
//  Created by Nacho Nachev on 4.12.17.
//  Copyright © 2017 Lykke. All rights reserved.
//

import UIKit
import RxSwift
import WalletCore

public class LWRxBlueAuthManagerCommunityUsersCount: NSObject {
    public typealias Packet = CommunityUsersCountPacket
    public typealias Result = ApiResult<Int>
    public typealias ResultType = Int
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


extension LWRxBlueAuthManagerCommunityUsersCount: AuthManagerProtocol {
    
    public func createPacket(withObserver observer: Any, params: Void) -> CommunityUsersCountPacket {
        return Packet(observer)
    }
    
    public func getSuccessResult(fromPacket packet: Packet) -> Result {
        guard let count = packet.count else {
            return Result.error(withData: ["Message":"Couldn't retreive community size."])
        }
        
        return Result.success(withData: count)
    }
}


public extension ObservableType where Self.E == ApiResult<Int> {
    public func filterSuccess() -> Observable<Int> {
        return map{$0.getSuccess()}.filterNil()
    }
    
    public func isLoading() -> Observable<Bool> {
        return map{$0.isLoading}
    }
}
