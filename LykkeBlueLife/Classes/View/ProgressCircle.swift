//
//  ProgressCircle.swift
//  LykkeBlueLife
//
//  Created by Vasil Garov on 11/24/17.
//  Copyright © 2017 Lykke Blue Life. All rights reserved.
//

import Foundation
import UIKit

fileprivate enum Metrics {
    static let strokeWidth: CGFloat = 20.0
}

class ProgressCircle: UIView {
    
    public var progress: Double = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0),
                                      radius: bounds.size.width / 2.0,
                                      startAngle: 0.0,
                                      endAngle: CGFloat(Double.pi * 2.0),
                                      clockwise: true)
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = AppTheme.profileProgressCircleEmptyColor.cgColor
        circleLayer.lineWidth = Metrics.strokeWidth
        layer.addSublayer(circleLayer)
    }
    
    private func updateProgress() {
        let center = CGPoint (x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        let circleRadius = bounds.size.width / 2.0
        let startAngle = 3 / 2 * Double.pi
        let endAngle = startAngle + 2 * progress * Double.pi
        let circlePath = UIBezierPath(arcCenter: center,
                                      radius: circleRadius,
                                      startAngle: CGFloat(startAngle),
                                      endAngle: CGFloat(endAngle),
                                      clockwise: true)
        
        let progressLayer = CAShapeLayer()
        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = AppTheme.profileProgressCircleFillColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = Metrics.strokeWidth
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd  = 1
        layer.addSublayer(progressLayer )
    }
}
