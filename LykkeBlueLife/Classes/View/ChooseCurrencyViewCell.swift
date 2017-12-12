//
//  ChooseCurrencyViewCell.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/28/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit

class ChooseCurrencyViewCell: UITableViewCell {
    @IBOutlet weak var imgRadioButton: UIImageView!
    @IBOutlet weak var lblCurrency: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // code common to all your cells goes here
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setActive(active: Bool)
    {
        
        if(active == true)
        {
            imgRadioButton.image = UIImage(named: "radiobuttonActive.png")
        }
        else{
            imgRadioButton.image = UIImage(named: "radiobuttonNormal.png")
        }
    }
    
}
