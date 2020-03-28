//
//  EditToolAudioDetailSettingsViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/30.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  设置里的改动放手后要生效，拖动波形图结束后的时候也要开始播

import UIKit

class EditToolAudioDetailSettingsViewController: EditToolBaseSettingsViewController {
    
    public var volumeClosure: ((_ value: Float) -> Void)?
    
    public var fadeInClosure: ((_ selected: Bool) -> Void)?
    
    public var fadeOutClosure: ((_ selected: Bool) -> Void)?
    
    public var chooseClosure: ((_ start: Double) -> Void)?
    
    public var isHiddenChoose: Bool = false {
        willSet {
            waveformView.isHidden = newValue
            audioChooseView.isHidden = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    override func operationDidFinish() {
        navigationController?.popViewController(animated: true)
    }
    
    public func update(_ segment: CompositionAudioSegment) {
        waveformView.update(segment.asset)
        waveformView.layoutIfNeeded()
        let offsetX = CGFloat(segment.timeRange.start.seconds) * EDIT_THUMB_CELL_SIZE
        waveformView.contentOffset = .init(x: offsetX - waveformView.contentInset.left, y: 0)
        sliderValueLabel.text = String(format: "%.0f%%", segment.volume * 100)
        fadeInSwitch.isOn = segment.isFadeIn
        fadeOutSwitch.isOn = segment.isFadeOut
    }
    
    private func initView() {
        view.addSubview(waveformView)
        view.addSubview(audioChooseView)
        view.addSubview(volumeLabel)
        view.addSubview(fadeInLabel)
        view.addSubview(fadeOutLabel)
        view.addSubview(sliderView)
        view.addSubview(sliderValueLabel)
        view.addSubview(fadeInSwitch)
        view.addSubview(fadeOutSwitch)
        waveformView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topBar.snp.bottom).offset(10)
            make.left.right.equalTo(self.view)
            make.height.equalTo(40)
        }
        audioChooseView.snp.makeConstraints { (make) in
            make.center.equalTo(self.waveformView)
            make.width.equalTo(SCREEN_WIDTH / 2)
            make.height.equalTo(40)
        }
        volumeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(SCREEN_PADDING_X)
            make.top.equalTo(self.waveformView.snp.bottom).offset(30)
        }
        sliderView.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-55)
            make.centerY.equalTo(self.volumeLabel)
            make.size.equalTo(CGSize(width: 120, height: 16))
        }
        sliderValueLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-SCREEN_PADDING_X)
            make.centerY.equalTo(self.volumeLabel)
        }
        fadeInLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.volumeLabel)
            make.top.equalTo(self.volumeLabel.snp.bottom).offset(30)
        }
        fadeInSwitch.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-SCREEN_PADDING_X)
            make.centerY.equalTo(self.fadeInLabel)
        }
        fadeOutLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.fadeInLabel)
            make.top.equalTo(self.fadeInLabel.snp.bottom).offset(30)
        }
        fadeOutSwitch.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-SCREEN_PADDING_X)
            make.centerY.equalTo(self.fadeOutLabel)
        }
    }
    
    //MARK: Action
    
    @objc
    func didChangeFadeInSwitch() {
        fadeInClosure?(fadeInSwitch.isOn)
    }
    
    @objc
    func didChangeFadeOutSwitch() {
        fadeOutClosure?(fadeOutSwitch.isOn)
    }
    
    @objc
    func sliderDidTouchUpInside() {
        volumeClosure?(sliderView.value)
    }
    
    @objc
    func sliderValueChanged() {
        sliderValueLabel.text = String(format: "%.0f%%", sliderView.value * 100)
    }
    
    //MARK: Getter
    
    private lazy var waveformView: EditToolAudioWaveFormView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = .init(width: EDIT_THUMB_CELL_SIZE, height: WAVEFORM_HEIGHT)
        let view = EditToolAudioWaveFormView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: WAVEFORM_HEIGHT), collectionViewLayout: layout)
        view.layer.cornerRadius = 4
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInset = .init(top: 0, left: SCREEN_WIDTH / 4, bottom: 0, right: 0)
        view.scrollDidEndOffsetXClosure = { [unowned self, view] (offsetX) in
            let start = Double(offsetX) / Double(EDIT_THUMB_CELL_SIZE)
            self.chooseClosure?(start)
        }
        return view
    }()
    
    private lazy var audioChooseView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = false
        let leftView = UIView()
        leftView.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        let rightView = UIView()
        rightView.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        let coverView = UIView()
        coverView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        let label = UILabel()
        label.text = "选中音频区域"
        label.textColor = UIColor.qe.hex(0xEEEEEE)
        label.font = UIFont.systemFont(ofSize: 13, weight: .light)
        view.addSubview(leftView)
        view.addSubview(rightView)
        view.addSubview(coverView)
        view.addSubview(label)
        leftView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(view)
            make.width.equalTo(10)
        }
        rightView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(view)
            make.width.equalTo(10)
        }
        coverView.snp.makeConstraints { (make) in
            make.left.equalTo(leftView.snp.right)
            make.right.equalTo(rightView.snp.left)
            make.top.bottom.equalTo(view)
        }
        label.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
        return view
    }()
    
    private lazy var volumeLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 15, weight: .light)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "音量调节"
        return view
    }()
    
    private lazy var fadeInLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 15, weight: .light)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "淡入"
        return view
    }()
    
    private lazy var fadeOutLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 15, weight: .light)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "淡出"
        return view
    }()
    
    private lazy var sliderView: UISlider = {
        let view = UISlider()
        view.minimumValue = 0
        view.maximumValue = 1
        view.value = 1
        view.setThumbImage(UIImage(named: "edit_music_detail_slider"), for: .normal)
        view.minimumTrackTintColor = UIColor.qe.hex(0xFA3E54)
        view.maximumTrackTintColor = UIColor.qe.hex(0xEEEEEE)
        view.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        view.addTarget(self, action: #selector(sliderDidTouchUpInside), for: .touchUpInside)
        return view
    }()
    
    private lazy var sliderValueLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14, weight: .light)
        view.textColor = UIColor.qe.hex(0xFA3E54)
        view.text = "100%"
        return view
    }()
    
    private lazy var fadeInSwitch: UISwitch = {
        let view = UISwitch()
        view.isOn = false
        view.onTintColor = UIColor.qe.hex(0xFA3E54)
        view.addTarget(self, action: #selector(didChangeFadeInSwitch), for: .valueChanged)
        return view
    }()
    
    private lazy var fadeOutSwitch: UISwitch = {
        let view = UISwitch()
        view.isOn = false
        view.onTintColor = UIColor.qe.hex(0xFA3E54)
        view.addTarget(self, action: #selector(didChangeFadeOutSwitch), for: .valueChanged)
        return view
    }()

}
