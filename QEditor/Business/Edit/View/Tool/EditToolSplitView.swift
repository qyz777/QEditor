//
//  EditToolSplitView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/9.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolSplitView: UIView {
    
    init() {
        super.init(frame: .zero)
        frame = .init(x: 0, y: 0, width: 30, height: 30)
        let path = UIBezierPath(roundedRect: frame, cornerRadius: 15)
        let circlePath = UIBezierPath(ovalIn: .init(x: 10, y: 10, width: 10, height: 10))
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.qe.hex(0xEEEEEE).cgColor
        layer.addSublayer(fillLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
