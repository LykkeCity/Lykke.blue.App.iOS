//
//  LoadingView.swift
//  LykkeBlueLife
//
//  Created by Nikola Bardarov on 8/28/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit

class LoadingView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    init() {
       let screenSize: CGRect = UIScreen.main.bounds
        let rect = CGRect(x:0, y:0,  width: screenSize.width,height: screenSize.height)
        super.init(frame: rect)
        
        let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        
        // Position Activity Indicator in the center of the main view
        myActivityIndicator.center = CGPoint(x: screenSize.width/2.0, y: screenSize.height/2.0)
        // If needed, you can prevent Acivity Indicator from hiding when stopAnimating() is called
        myActivityIndicator.hidesWhenStopped = false
        // Start Activity Indicator
        myActivityIndicator.startAnimating()
        myActivityIndicator.isHidden = false
        // Call stopAnimating() when need to stop activity indicator
        //myActivityIndicator.stopAnimating()
        self.addSubview(myActivityIndicator)
        self.backgroundColor  = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.5)
    
        
    }
    
    // This attribute hides `init(coder:)` from subclasses
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("NSCoding not supported")
    }
    

}
