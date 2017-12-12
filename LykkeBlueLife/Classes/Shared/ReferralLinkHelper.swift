//
//  ReferralLinkHelper.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 12/6/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import WalletCore
import RxSwift

class ReferralLinkHelper {
    
    private let disposeBag = DisposeBag()
    
    func isInvitationLink(_ url: String, completion: @escaping (Bool) -> ()) {
        let referralId = parseReferralId(forUrl: url)
        LWRxBlueAuthManager.instance.referralLinkInfo.request(withParams: referralId)
            .filterSuccess()
            .subscribe(onNext: { result in
                completion(result.isInvitationType)
            })
            .disposed(by: disposeBag)
    }
    
    func parseReferralId(forUrl url: String) -> String {
        let components = url.components(separatedBy: "/")
        return components[components.count - 1]
    }
}
