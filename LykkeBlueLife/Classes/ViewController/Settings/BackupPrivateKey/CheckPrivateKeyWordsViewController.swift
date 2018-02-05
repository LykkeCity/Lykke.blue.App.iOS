//
//  CheckPrivateKeyWordsViewController.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 1.02.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import UIKit
import WalletCore
import RxCocoa
import RxSwift

class CheckPrivateKeyWordsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var confirmButton: UIButton!
    
    fileprivate let disposeBag = DisposeBag()
    var words: [String] = []
    
    lazy var viewModel: BackupPrivateKeyViewModel = {
        let params = BackupPrivateKeyViewModel.Params(words: self.words,
                                                      font: self.textField.font,
                                                      typingColor: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),
                                                      correctColor: #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),
                                                      wrongColor: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
        
        return BackupPrivateKeyViewModel(params: params, authManager: LWRxAuthManager.instance)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        
        textField.rx.text
        .map { [weak textField] in return ($0, textField!.isEditing) }
        .asDriver(onErrorJustReturn: (nil, false))
        .drive(viewModel.typedText)
        .disposed(by: disposeBag)
        
        viewModel.colorizedText
        .subscribe(onNext: { [textField] (attributedText) in
            textField?.setAttributedTextAndPreserveState(attributedText)
        })
        .disposed(by: disposeBag)
        
        viewModel.areAllWordsCorrect
            .asDriver(onErrorJustReturn: false)
            .drive(confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.areAllWordsCorrect
        .distinctUntilChanged()
        .filter { $0 }
        .subscribe(onNext: { [textField, viewModel] _ in
            textField?.resignFirstResponder()
            viewModel.confirmTrigger.onNext(())
        })
        .disposed(by: disposeBag)
        
        confirmButton.rx.tap
        .bind { [viewModel] in viewModel.confirmTrigger.onNext(()) }
        .disposed(by: disposeBag)
        
        viewModel.loadingViewModel.isLoading
        .asDriver(onErrorJustReturn: false)
        .drive(rx.loading)
        .disposed(by: disposeBag)
        
        viewModel.errors
        .asDriver(onErrorJustReturn: [:])
        .drive(rx.error)
        .disposed(by: disposeBag)
        
        viewModel.success
        .asDriver(onErrorJustReturn: ())
        .drive(onNext: { [weak self] _ in
            self?.performSegue(withIdentifier: "backupCompleted", sender: nil)
        })
        .disposed(by: disposeBag)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CheckPrivateKeyWordsViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true
        }
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        let wordsCount = newText.components(separatedBy: " ").count
        let shouldChange = newText.range(of: "  ") == nil && wordsCount <= words.count
        return shouldChange
    }
}

extension UITextField {
    
    fileprivate func setAttributedTextAndPreserveState(_ attributedText: NSAttributedString) {
        let selectedTextRange = self.selectedTextRange
        let bounds = self.textInputView.superview!.bounds
        self.attributedText = attributedText
        self.textInputView.superview?.bounds = bounds
        self.selectedTextRange = selectedTextRange
    }
    
}
