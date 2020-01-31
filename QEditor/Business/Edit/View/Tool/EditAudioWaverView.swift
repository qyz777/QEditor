//
//  EditAudioWaverView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/31.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  录音波形图

import UIKit
import AVFoundation

public class EditAudioWaverView: UIView {

    public weak var recorder: AVAudioRecorder? {
        willSet {
            displayLink?.invalidate()
            displayLink = CADisplayLink(target: self, selector: #selector(setupRecorderLevel))
            displayLink?.add(to: RunLoop.current, forMode: .common)
            setup()
        }
    }
    
    /// 波纹数量
    public var numberOfWaves = 5
    
    /// 波纹颜色
    public var waveColor: UIColor = .white
    
    /// 主波纹宽度
    public var mainWaveWidth: CGFloat = 2
    
    /// 副波纹宽度
    public var decorativeWavesWidth: CGFloat = 1.0
    
    /// 最小振幅
    public var idleAmplitude: CGFloat = 0.01
    
    /// 频率
    public var frequency: CGFloat = 1.2
    
    /// 振幅
    public private(set) var amplitude: CGFloat = 1.0
    
    /// 密度
    public var density: CGFloat = 1.0
    
    public var phaseShift: CGFloat = -0.25
    
    private var waves: [CAShapeLayer] = []
    
    private var waveHeight: CGFloat {
        return height
    }
    
    private var waveWidth: CGFloat {
        return width
    }
    
    private var waveMid: CGFloat {
        return waveHeight / 2.0
    }
    
    private var maxAmplitude: CGFloat {
        return waveHeight - 4.0
    }
    
    private var phase: CGFloat = 0
    
    private var level: CGFloat = 0 {
        willSet {
            phase += phaseShift
            amplitude = max(newValue, idleAmplitude)
            updateMeters()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        displayLink?.invalidate()
    }
    
    private func setup() {
        for i in 0..<numberOfWaves {
            let waveLine = CAShapeLayer()
            waveLine.lineCap = .butt
            waveLine.lineJoin = .round
            waveLine.strokeColor = UIColor.clear.cgColor
            waveLine.fillColor = UIColor.clear.cgColor
            waveLine.lineWidth = i == 0 ? mainWaveWidth : decorativeWavesWidth
            let progress = 1 - CGFloat(i) / CGFloat(numberOfWaves)
            let multiplier = min(1, (progress / 3.0 * 2.0) + (1.0 / 3.0))
            let color = waveColor.withAlphaComponent(i == 0 ? 1.0 : 1.0 * multiplier)
            waveLine.strokeColor = color.cgColor
            layer.addSublayer(waveLine)
            waves.append(waveLine)
        }
    }
    
    private func updateMeters() {
        for i in 0..<numberOfWaves {
            let path = UIBezierPath()
            let progress = 1.0 - CGFloat(i) / CGFloat(numberOfWaves)
            let normedAmplitude = (1.5 * progress - 0.5) * amplitude
            var x: CGFloat = 0
            while x < waveWidth + density {
                let amplitude = maxAmplitude * normedAmplitude
                let m = CGFloat(sinf(Float(2 * CGFloat.pi * (x / waveWidth) * frequency + phase)))
                let y = amplitude * m + waveHeight * 0.5
                if x == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                x += density
            }
            waves[i].path = path.cgPath
        }
    }
    
    @objc
    private func setupRecorderLevel() {
        guard let recorder = recorder else { return }
        recorder.updateMeters()
        let normalizedValue = pow(10, recorder.averagePower(forChannel: 0) / 10)
        level = CGFloat(normalizedValue)
    }
    
    var displayLink: CADisplayLink?

}
