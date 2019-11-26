//
//  EditToolWaveformCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/24.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

fileprivate let HEIGHT_SCALING: CGFloat = 0.9

class EditToolWaveformCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(drawView)
        drawView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func update(_ samples: [CGFloat]) {
        drawView.update(samples)
    }
    
    private lazy var drawView: WaveformDrawView = {
        let view = WaveformDrawView(frame: frame)
//        view.backgroundColor = .clear
        return view
    }()
    
}

private class WaveformDrawView: UIView {
    
    private let path = UIBezierPath()
    
    private var samples: [CGFloat] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.drawsAsynchronously = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func update(_ samples: [CGFloat]) {
        self.samples = samples
        path.removeAllPoints()
        let centerY = center.y
        DispatchQueue.global().async {
            var i = 0
            samples.forEach {
                let p = UIBezierPath()
                p.move(to: CGPoint(x: CGFloat(i), y: centerY))
                p.addLine(to: CGPoint(x: CGFloat(i), y: centerY - $0 * HEIGHT_SCALING))
                p.addLine(to: CGPoint(x: CGFloat(i), y: centerY + $0 * HEIGHT_SCALING))
                self.path.append(p)
                i += 1
            }
            DispatchQueue.main.sync {
                self.layer.setNeedsDisplay()
            }
        }
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        ctx.setStrokeColor(UIColor.qe.hex(0xF5F5F5).cgColor)
        ctx.setLineWidth(1)
        ctx.addPath(path.cgPath)
        ctx.strokePath()
    }
    
    
}
