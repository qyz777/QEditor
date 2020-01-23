//
//  EditToolChangeSpeedViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolChangeSpeedViewController: EditToolBaseSettingsViewController {
    
    public var closure: ((_ progress: Float) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(sliderView)
        view.addSubview(leftLabel)
        view.addSubview(rightLabel)
        view.addSubview(currentProgressLabel)
        
        sliderView.snp.makeConstraints { (make) in
            make.center.equalTo(self.view)
            make.height.equalTo(16)
            make.left.equalTo(self.leftLabel.snp.right).offset(SCREEN_PADDING_X)
            make.right.equalTo(self.rightLabel.snp.left).offset(-SCREEN_PADDING_X)
        }
        
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(SCREEN_PADDING_X)
            make.centerY.equalTo(self.sliderView)
        }
        
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-SCREEN_PADDING_X)
            make.centerY.equalTo(self.sliderView)
        }
        
        currentProgressLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.sliderView)
            make.bottom.equalTo(self.sliderView.snp.top).offset(-10)
        }
    }
    
    override func operationDidFinish() {
        closure?(sliderView.value)
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func sliderValueDidChange(_ sender: UISlider) {
        currentProgressLabel.text = String(format: "当前: %.1f", sender.value)
    }
    
    lazy var sliderView: UISlider = {
        let view = UISlider()
        view.maximumValue = 4
        view.minimumValue = 0.1
        view.isContinuous = true
        view.value = 1
        view.minimumTrackTintColor = UIColor.qe.hex(0xFA3E54)
        view.addTarget(self, action: #selector(sliderValueDidChange), for: .valueChanged)
        return view
    }()
    
    lazy var leftLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.textColor = .white
        view.text = "0.1"
        return view
    }()
    
    lazy var rightLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14)
        view.textColor = .white
        view.text = "4"
        return view
    }()
    
    lazy var currentProgressLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15, weight: .semibold)
        view.textColor = .white
        view.text = "当前: 1"
        return view
    }()

}
