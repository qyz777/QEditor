//
//  EditToolAdjustProgressView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

struct AdjustProgressViewInfo {
    let startValue: Float
    let endValue: Float
    let currentValue: Float
}

class EditToolAdjustProgressView: UIView {
    
    public var progress: Float {
        return sliderView.value
    }
    
    public var progressChangeClosure: ((_ progress: Float) -> Void)?
    
    init(info: AdjustProgressViewInfo) {
        super.init(frame: .zero)
        setupSubviews()
        sliderView.maximumValue = info.endValue
        sliderView.minimumValue = info.startValue
        sliderView.value = info.currentValue
        leftLabel.text = String(format: "%.1f", info.startValue)
        rightLabel.text = String(format: "%.1f", info.endValue)
        currentProgressLabel.text = String(format: "%.1f", info.currentValue)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupSubviews() {
        addSubview(sliderView)
        addSubview(leftLabel)
        addSubview(rightLabel)
        addSubview(currentProgressLabel)
        
        sliderView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(SCREEN_WIDTH / 3 * 2)
        }
        
        leftLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.sliderView.snp.left).offset(-15)
            make.centerY.equalTo(self.sliderView)
        }
        
        rightLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.sliderView.snp.right).offset(15)
            make.centerY.equalTo(self.sliderView)
        }
        
        currentProgressLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.sliderView)
            make.bottom.equalTo(self.sliderView.snp.top).offset(-10)
        }
    }
    
    @objc
    func sliderValueDidChange(_ sender: UISlider) {
        currentProgressLabel.text = String(format: "%.1f", sender.value)
    }
    
    @objc
    func sliderTouchUpInside(_ sender: UISlider) {
        progressChangeClosure?(sender.value)
    }
    
    lazy var sliderView: UISlider = {
        let view = UISlider()
        view.maximumValue = 1
        view.minimumValue = 0
        view.isContinuous = true
        view.value = 1
        view.minimumTrackTintColor = UIColor.qe.hex(0xFA3E54)
        view.addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
        view.addTarget(self, action: #selector(sliderTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    
    lazy var leftLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12)
        view.textColor = .white
        return view
    }()
    
    lazy var rightLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 12)
        view.textColor = .white
        return view
    }()
    
    lazy var currentProgressLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13, weight: .semibold)
        view.textColor = .white
        return view
    }()

}
