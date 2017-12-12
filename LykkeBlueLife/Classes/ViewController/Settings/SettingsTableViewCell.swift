//
//  SettingsTableViewCell.swift
//  LykkeBlueLife
//
//  Created by Georgi Stanev on 2.12.17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet weak var nextWidth: NSLayoutConstraint!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var label: UILabel!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backroundView = UIView()
        backroundView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1967840325)
        selectedBackgroundView = backroundView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(toSetting item: SettingItem) {
        disposeBag = DisposeBag()
        
        item.handler.label
            .drive(label.rx.text)
            .disposed(by: disposeBag)
        
        if item.handler.nextArrowIsHidden {
            nextWidth.constant = 0
        }
        
        item.handler.value
            .drive(value.rx.text)
            .disposed(by: disposeBag)
    }

}
