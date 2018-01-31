//
//  SkyFloatingLabelTextFieldWithExtensions.swift
//  LykkeBlueLife
//
//  Created by Mac X on 8/23/17.
//  Copyright © 2017 Nikola Bardarov. All rights reserved.
//

import UIKit

let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);

extension SkyFloatingLabelTextField
{
    enum Direction
    {
        case Left
        case Right
    }
    
    func AddImage(direction:Direction,imageName:String,Frame:CGRect,backgroundColor:UIColor)
    {
        let View = UIView(frame: Frame)
        View.backgroundColor = backgroundColor
        
        let imageView = UIImageView(frame: Frame)
        imageView.image = UIImage(named: imageName)
        
        View.addSubview(imageView)
        
        if Direction.Left == direction
        {
            self.leftViewMode = .always
            self.leftView = View
        }
        else
        {
            self.rightViewMode = .always
            self.rightView = View
        }
    }
    
    func addButtonOnTextField(_ withImageName: String) -> (UIButton){
        let button = UIButton(type: .custom)
        //button.backgroundColor = .red
        button.setImage(UIImage(named: withImageName), for: .normal)
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 50), y: CGFloat(5), width: CGFloat(70), height: CGFloat(40))
        //button.addTarget(self, action: selector, for: .touchUpInside)
        self.rightView = button
        self.rightViewMode = .always
        return button
    }
    
    func roundCorners(corners:UIRectCorner, radius: CGFloat, border: Bool) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.masksToBounds = true
        self.layer.mask = mask
        
        if border{
            self.borders(path: path)
        }
    }
    
    func borders(path: UIBezierPath){
        let borderLayer: CAShapeLayer = CAShapeLayer()
        borderLayer.frame = self.bounds
        borderLayer.path = path.cgPath
        borderLayer.lineWidth = 1.0
        let borderColor = UIColor(red: 235.0, green: 237.0 / 255.0, blue: 239.0 / 255.0, alpha: 1.0)
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(borderLayer)
    }
}

