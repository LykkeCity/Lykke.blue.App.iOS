//
//  InviteButton.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/14/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import UIKit

fileprivate enum Predefined {
    static let title = "invite friends"
    static let imageName = "Invite"
    static let margin: CGFloat = -25.0
}

public class InviteButton: UIButton {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        customize()
    }
    
    private func customize() {
        backgroundColor = AppTheme.inviteButtonBackgroundColor
        titleLabel?.font = AppTheme.inviteButtonFont
        
        adjustsImageWhenHighlighted = false
        
        setImage(UIImage(named: Predefined.imageName), for: .normal)
        setTitle(Predefined.title, for: .normal)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: Predefined.margin, bottom: 0, right: 0)
    }
    
}
