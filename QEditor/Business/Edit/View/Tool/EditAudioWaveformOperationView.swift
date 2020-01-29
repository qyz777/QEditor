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
                strongSelf.samples = samples
                strongSelf.drawAudioWaveform(from: samples)
                strongSelf.titleLabel.text = segment.title
            }
        }
    }
    
    public private(set) var isShowing = false
    
    public var selectedClosure: ((_ isSelected: Bool) -> Void)?
    
    public var handleLeftPanClosure: ((_ pan: UIPanGestureRecognizer) -> Void)?
    
    public var handleRightPanClosure: ((_ pan: UIPanGestureRecognizer) -> Void)?
    
    private var samples: [CGFloat] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(waveformView)
        addSubview(leftPanView)
        addSubview(rightPanView)
        addSubview(coverView)
        addSubview(titleLabel)
        waveformView.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(EDIT_AUDIO_WAVEFORM_SIZE)
        }
        leftPanView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(15)
        }
        rightPanView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(self)
            make.width.equalTo(15)
        }
        coverView.snp.makeConstraints { (make) in
            make.left.equalTo(self.leftPanView.snp.right)
            make.right.equalTo(self.rightPanView.snp.left)
            make.top.bottom.equalTo(self)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.leftPanView.snp.right).offset(2)
            make.right.equalTo(self.rightPanView.snp.left).offset(-2)
            make.centerY.equalTo(self)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: width, height: EDIT_AUDIO_WAVEFORM_SIZE)
        if samples.count > 0 {
            drawAudioWaveform(from: samples)
        }
    }
    
    public func showOperationView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.leftPanView.alpha = 1
            self.rightPanView.alpha = 1
            self.coverView.alpha = 1
        }) { (completed) in
            self.isShowing = true
        }
    }
    
    public func hiddenOperationView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.leftPanView.alpha = 0
            self.rightPanView.alpha = 0
            self.coverView.alpha = 0
        }) { (completed) in
            self.isShowing = false
        }
    }
    
    @objc
    private func handleLeftPan(_ gesture: UIPanGestureRecognizer) {
        handleLeftPanClosure?(gesture)
    }
    
    @objc
    private func handleRightPan(_ gesture: UIPanGestureRecognizer) {
        handleRightPanClosure?(gesture)
    }
    
    @objc
    private func handleTap(_ tap: UITapGestureRecognizer) {
        selectedClosure?(!isShowing)
        if isShowing {
            hiddenOperationView()
        } else {
            showOperationView()
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
    
    private lazy var waveformView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var leftPanView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        view.alpha = 0
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleLeftPan(_:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    
    private lazy var rightPanView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        view.alpha = 0
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleRightPan(_:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    
    private lazy var coverView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 11, weight: .light)
        return view
    }()
    
    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.qe.hex(0xEEEEEE).cgColor
        return shapeLayer
    }()

}
