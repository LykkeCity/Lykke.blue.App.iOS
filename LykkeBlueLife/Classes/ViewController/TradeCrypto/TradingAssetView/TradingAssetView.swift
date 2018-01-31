//
//  TradingAssetView.swift
//  LykkeBlueLife
//
//  Created by Georgi Ivanov on 22.01.18.
//  Copyright © 2018 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import WalletCore

// TODO: find out why view doesn't visualize in storyboard
@IBDesignable
class TradingAssetView: UIView {
    
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var baseAssetCode: UILabel!
    @IBOutlet weak var amountInBase: UILabel!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var assetCode: UILabel!
    @IBOutlet weak var assetName: UILabel!
    @IBOutlet weak var assetIcon: UIImageView!
    @IBOutlet weak var downArrowIcon: UIImageView!
    
    
    private var contentView: UIView?
    private let nibName = "TradingAssetView"
    
    let itemPicker = (picker: UIPickerView(), field: UITextField())
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        xibSetup()
    }
    
    func xibSetup() {
        guard let view = loadViewFromNib() else {
            return
        }
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func setupUX(width: CGFloat, disposedBy disposeBag: DisposeBag) {
        itemPicker.field.inputView = itemPicker.picker
        addSubview(itemPicker.field)
        
        setupFormUX(forWidth: width, disposedBy: disposeBag)
        
        tapGesture.rx.event.asObservable()
            .debug()
            .subscribe(onNext: {[weak self] _ in
                self?.itemPicker.field.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        xibSetup()
        contentView?.prepareForInterfaceBuilder()
    }
}

extension TradingAssetView: InputForm {
    
    var textFields: [UITextField] { return [itemPicker.field] }
    
    func submitForm() {}
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return goToTextField(after: textField)
    }
    
}
