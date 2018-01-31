//
//  Twitter+Rx.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 8.12.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import TwitterKit
import WalletCore

fileprivate class TwitterState {
    static let instance = TwitterState()
    let isLoggedIn: BehaviorSubject<Bool>
    
    private init() {
        isLoggedIn = BehaviorSubject(value: Twitter.sharedInstance().sessionStore.hasLoggedInUsers())
    }
}

extension Reactive where Base: Twitter {
    
    var isLoggedIn: Observable<Bool> {
        return TwitterState.instance.isLoggedIn.asObservable()
    }
    
    func logout() -> Observable<Void> {
        
        return Observable
            .create{ [base] observer in
            
                base.sessionStore.existingUserSessions()
                    .map{ $0 as? TWTRSession }
                    .flatMap{ $0 }
                    .map{ $0.userID }
                    .forEach{ [base] userId in
                        base.sessionStore.logOutUserID(userId)
                    }
                
                TwitterState.instance.isLoggedIn.onNext(false)
                observer.onNext(Void())
                observer.onCompleted()
                
                return Disposables.create()
            }
            .shareReplay(1)
    }
    
    func login() -> Observable<ApiResult<TWTRSession>> {

        return Observable
            .create{ [base] observer in

                base.logIn { session, error in
                    guard let session = session else {
                        TwitterState.instance.isLoggedIn.onNext(false)
                        observer.onNext(.error(withData: ["Message": error?.localizedDescription ?? "Error occured."]))
                        observer.onCompleted()
                        return
                    }
                    
                    TwitterState.instance.isLoggedIn.onNext(true)
                    observer.onNext(.success(withData: session))
                    observer.onCompleted()
                }
                
                return Disposables.create()
            }
            .shareReplay(1)
    }
}


extension Observable where Element == ApiResult<TWTRSession> {
    func filterSuccess() -> Observable<TWTRSession> {
        return map{ $0.getSuccess() }.filterNil()
    }
    
    func isLoading() -> Observable<Bool> {
        return map{ $0.isLoading }
    }
    
    public func filterError() -> Observable<[AnyHashable : Any]> {
        return map{ $0.getError() }.filterNil()
    }
}

