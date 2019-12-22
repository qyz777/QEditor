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

    public var closure: ((_ progress: Float) -> Void)?
    
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
        addSubview(okButton)
        addSubview(cancelButton)
        addSubview(sliderView)
        addSubview(leftLabel)
        addSubview(rightLabel)
        addSubview(currentProgressLabel)
        
        cancelButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(SCREEN_PADDING_X)
        }
        
        okButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self).offset(-SCREEN_PADDING_X)
        }
        
        sliderView.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(SCREEN_WIDTH / 2)
        }
        
        leftLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.sliderView.snp.left).offset(-5)
            make.centerY.equalTo(self.sliderView)
        }
        
        rightLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.sliderView.snp.right).offset(5)
            make.centerY.equalTo(self.sliderView)
        }
        
        currentProgressLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.sliderView)
            make.bottom.equalTo(self.sliderView.snp.top).offset(-5)
        }
    }
    
    @objc
    func didClickOkButton() {
        closure?(sliderView.value)
        removeFromSuperview()
    }
    
    @objc
    func didClickCancelButton() {
        removeFromSuperview()
    }
    
    @objc
    func sliderValueDidChange(_ sender: UISlider) {
        currentProgressLabel.text = String(format: "%.1f", sender.value)
    }
    
    lazy var sliderView: UISlider = {
        let view = UISlider()
        view.maximumValue = 1
        view.minimumValue = 0
        view.isContinuous = true
        view.value = 1
        view.minimumTrackTintColor = UIColor.qe.hex(0xFA3E54)
        view.addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
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
    
    lazy var okButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("完成", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 13)
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(didClickOkButton), for: .touchUpInside)
        return view
    }()
    
    lazy var cancelButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("取消", for: .normal)
        view.titleLabel?.font = .systemFont(ofSize: 13)
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(didClickCancelButton), for: .touchUpInside)
        return view
    }()

}
