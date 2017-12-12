//
//  TwitterTimelineDatasource.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 27.11.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import TwitterKit
import WalletCore
import RxSwift

class TwitterTimelineDataSource: NSObject, TWTRTimelineDataSource {
    var timelineFilter: TWTRTimelineFilter?
    var timelineType: TWTRTimelineType
    var apiClient: TWTRAPIClient
    let authManager: LWRxBlueAuthManager
    
    var disposeBag = DisposeBag()
    
    fileprivate static let pageSize = 10
    
    init(apiClient: TWTRAPIClient, authManager: LWRxBlueAuthManager = LWRxBlueAuthManager.instance) {
        self.timelineType = .search
        self.apiClient = apiClient
        self.authManager = authManager
        super.init()
    }
    
    func getBody(beforePosition position: String?) -> TwitterTimeLineJsonPacket.Body {
        var body = TwitterTimeLineJsonPacket.Body(
            accountEmail: AppConstants.Twitter.accountEmail,
            searchQuery: AppConstants.Twitter.hashTag
        )
        
        body.pageSize = TwitterTimelineDataSource.pageSize
        
        guard let position = position, let positionInt = Int(position) else {
            body.pageNumber = 1
            return body
        }
        
        body.pageNumber = positionInt.nextPage(byPageSize: TwitterTimelineDataSource.pageSize)
        
        return body
    }
    
    func loadPreviousTweets(beforePosition position: String?, completion: @escaping TWTRLoadTimelineCompletion) {
        
        let body = getBody(beforePosition: position)
        
        authManager.twitterJson
            .request(withParams: body)
            .filterSuccess()
            .mapToTweets()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { tweets in
                completion(tweets, body.asCursor(newTweets: tweets), nil)
            })
            .disposed(by: disposeBag)
    }
}

fileprivate extension TWTRTimelineCursor {
    convenience init(body: TwitterTimeLineJsonPacket.Body, tweets: [TWTRTweet]) {
        let pageNumber = body.pageNumber ?? 1
        let pageSize = body.pageSize ?? TwitterTimelineDataSource.pageSize
        
        let minPosition = pageNumber * pageSize
        let maxPosition = minPosition + tweets.count
            
        self.init(maxPosition: String(maxPosition), minPosition: String(minPosition))
    }
}

fileprivate extension TwitterTimeLineJsonPacket.Body {
    func asCursor(newTweets: [TWTRTweet]) -> TWTRTimelineCursor {
        return TWTRTimelineCursor(body: self, tweets: newTweets)
    }
}

fileprivate extension ObservableType where Self.E == [[AnyHashable : Any]] {
    func mapToTweets() -> Observable<[TWTRTweet]> {
        return map{
            $0.map{ json -> TWTRTweet? in
                var json: [AnyHashable: Any] = json
                
                json["lang"] = String(describing: json["lang"])
                
                let createdAt = json["created_at"] as? String ?? ""
                json["created_at"] = createdAt.formatDate()
                
                return TWTRTweet(jsonDictionary: json)
            }
            .flatMap{ $0 }
        }
    }
}

fileprivate extension String {
    func formatDate() -> String? {
        let dateFormatterIso = DateFormatter()
        dateFormatterIso.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatterIso.locale = Locale(identifier: "en_US")
        
        guard let date = dateFormatterIso.date(from: self) else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
        
        return dateFormatter.string(from: date)
    }
}

fileprivate extension Int {
    func nextPage(byPageSize pageSize: Int) -> Int {
        return (self / pageSize) + 1
    }
}
