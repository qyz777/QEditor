//
//  EditOperationAudioCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/6.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

struct EditOperationAudioCellModel: EditOperationCellModel {
    var width: CGFloat
    var cellClass: AnyClass
    var start: CGFloat
    var maxWidth: CGFloat
    var segment: CompositionAudioSegment
    let title: String
}

class EditOperationAudioCell: EditOperationCell {
    
    var samples: [CGFloat] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        addSubview(waveformView)
        addSubview(titleLabel)
        waveformView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.leftPanView.snp.right).offset(2)
            make.right.equalTo(self.rightPanView.snp.left).offset(-2)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        if samples.count > 0 {
            drawAudioWaveform(from: samples)
        }
    }
    
    override func update(_ model: EditOperationCellModel) {
        super.update(model)
        guard let model = model as? EditOperationAudioCellModel else { return }
        titleLabel.text = model.title
        let width = CGFloat(model.segment.duration) * EDIT_OPERATION_VIEW_MIN_WIDTH
        let size = CGSize(width: width, height: EDIT_OPERATION_VIEW_HEIGHT)
        model.segment.loadAudioSamples(for: size) { [weak self] (samples) in
            guard let strongSelf = self else { return }
            strongSelf.samples = samples
            strongSelf.drawAudioWaveform(from: samples)
        }
    }
    
    private func drawAudioWaveform(from samples: [CGFloat]) {
        let midY = bounds.size.height / 2
        let topPath = UIBezierPath()
        let bottomPath = UIBezierPath()
        topPath.move(to: .init(x: 0, y: midY))
        bottomPath.move(to: .init(x: 0, y: midY))
        var i = 0
        while i < samples.count {
            if CGFloat(i * BOX_SAMPLE_WIDTH) >= width {
                break
            }
            let sample = samples[i]
            topPath.addLine(to: CGPoint(x: CGFloat(i * BOX_SAMPLE_WIDTH), y: midY - sample * HEIGHT_SCALING))
            bottomPath.addLine(to: CGPoint(x: CGFloat(i * BOX_SAMPLE_WIDTH), y: midY + sample * HEIGHT_SCALING))
            i += BOX_SAMPLE_WIDTH
        }
        topPath.addLine(to: .init(x: width, y: midY))
        bottomPath.addLine(to: .init(x: width, y: midY))
        let fullPath = UIBezierPath()
        fullPath.append(topPath)
        fullPath.append(bottomPath)
        shapeLayer.fillColor = UIColor.qe.hex(0xEEEEEE).cgColor
        shapeLayer.path = fullPath.cgPath
        waveformView.layer.addSublayer(shapeLayer)
    }
    
    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.qe.hex(0xEEEEEE).cgColor
        return shapeLayer
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 11, weight: .light)
        view.alpha = 0
        return view
    }()
    
    private lazy var waveformView: UIView = {
        let view = UIView()
        return view
    }()

}
