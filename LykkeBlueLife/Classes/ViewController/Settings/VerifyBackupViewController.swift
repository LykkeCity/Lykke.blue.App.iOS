//
//  VerifyBackupViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 10/26/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa


typealias ValidatedResult = (text: String, validArray: [Bool])

class VerifyBackupViewController: UIViewController {
    
    @IBOutlet weak var backup: UITextField!
    
    var backupWords: [String]?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextChangeHandling()
    }
    
    private func setupTextChangeHandling() {
        guard let backupWords = backupWords else { return }
        
        let validatedStrings = backup.rx.text.asObservable()
            .filterNil()
            .validate(backupWords: backupWords)
        
        validatedStrings
            .debug("vv highlight words ", trimOutput: false)
            .mapToHighlightedText()
            .subscribe(onNext: {[backup] attributedText in
                guard let backup = backup else { return }
                
                let preAttributedRange = backup.selectedTextRange
                backup.attributedText = attributedText
                backup.selectedTextRange = preAttributedRange
            })
            .disposed(by: disposeBag)
        
        validatedStrings
            .filter{ validatedStrings in
                validatedStrings.validArray.filter{$0}.count == backupWords.count
            }
            .debug("vv make request ", trimOutput: false)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
}

extension ObservableType where Self.E == String {
    func validate(backupWords: [String]) -> Observable<ValidatedResult> {
        return
            filter{ text -> Bool in
                text.last == " " || text.split().count == backupWords.count
            }
            .map{ text -> (text: String, splitArray: [String]) in
                (text: text, splitArray: text.split())
            }
            .map{ data -> ValidatedResult in
                let validArray = data.splitArray.enumerated()
                    .map{ data in
                        backupWords[data.offset] == data.element
                    }
                
                return ValidatedResult(text: data.text, validArray: validArray)
            }
    }
}

extension ObservableType where Self.E == ValidatedResult {
    func mapToHighlightedText() -> Observable<NSAttributedString> {
        return map{validatedResult in
            let text = validatedResult.text
            let validArray = validatedResult.validArray
            
            let attributedText = NSMutableAttributedString(string: text)
            
            for (valid, string) in zip(validArray, text.split(separator: " ")) {
                if valid {
                    attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.green, range: NSRange(text.range(of: string)!, in: text))
                } else {
                    attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.red, range: NSRange(text.range(of: string)!, in: text))
                }
            }
            
            return attributedText
        }
    }
}

extension String {
    func split() -> [String] {
        return components(separatedBy: " ").filter{ $0.isNotEmpty }
    }
}
