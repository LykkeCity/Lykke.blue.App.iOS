//
//  BackupViewController.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 10/25/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit
import WalletCore

enum ActionType {
    static let next = "Next"
    static let previous = "Back"
}

class BackupViewController: UIViewController {
     
    @IBOutlet weak var word: UILabel!
    @IBOutlet weak var step: UILabel!
    
    private var index = 0
    
    lazy var backupWords: [String] = {
        return LWPrivateKeyManager.shared().privateKeyWords() as? [String] ?? []
    }()
    
    private var formattedSteps: String {
        return "\(index + 1) of \(backupWords.count)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupLabels()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == AppConstants.Segue.showVerifyBackup,
            let toViewController = segue.destination as? VerifyBackupViewController {
            toViewController.backupWords = backupWords
        }
    }
    
    private func setupNavigationBar() {
        let rightButtonItem = UIBarButtonItem(title: ActionType.next,
                                              style: .done,
                                              target: self,
                                              action: #selector(navigationItemTapped(sender:)))
        navigationItem.rightBarButtonItem = rightButtonItem
        
        let backButtonItem = UIBarButtonItem(title: ActionType.previous,
                                             style: .plain,
                                             target: self,
                                             action: #selector(navigationItemTapped(sender:)))
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    private func setupLabels() {
        step.text = formattedSteps
        word.text = backupWords[index]
    }
    
    func navigationItemTapped(sender: UIBarButtonItem) {
        switch sender.title ?? "" {
            case ActionType.next:
                showNextWord()
            case ActionType.previous:
                showPreviousWord()
            default:
                return
        }
    }
    
    private func showNextWord() {
        guard index < backupWords.count - 1 else {
            performSegue(withIdentifier: AppConstants.Segue.showVerifyBackup, sender: self)
            return
        }
        
        index += 1
        word.text = backupWords[index]
        step.text = formattedSteps
    }
    
    private func showPreviousWord() {
        guard index > 0 else {
            navigationController?.popViewController(animated: true)
            return
        }
        
        index -= 1
        word.text = backupWords[index]
        step.text = formattedSteps
    }
}
