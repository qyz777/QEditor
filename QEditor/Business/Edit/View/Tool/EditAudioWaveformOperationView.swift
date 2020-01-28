//
//  EditAudioWaveformOperationView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/27.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

let EDIT_AUDIO_WAVEFORM_SIZE: CGFloat = 40

class EditAudioWaveformOperationView: UIView {
    
    public var segment: EditCompositionAudioSegment? {
        willSet {
            guard let segment = newValue else { return }
            let width = CGFloat(segment.duration) * EDIT_AUDIO_WAVEFORM_SIZE
            let size = CGSize(width: width, height: EDIT_AUDIO_WAVEFORM_SIZE)
            segment.loadAudioSamples(for: size) { [weak self] (samples) in
                guard let strongSelf = self else { return }
                strongSelf.drawAudioWaveform(from: samples)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(waveformView)
        waveformView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(EDIT_AUDIO_WAVEFORM_SIZE)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func drawAudioWaveform(from samples: [CGFloat]) {
        let midY = bounds.size.height / 2
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: width, height: EDIT_AUDIO_WAVEFORM_SIZE)
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
    
    lazy var waveformView: UIView = {
        let view = UIView()
        return view
    }()

}
