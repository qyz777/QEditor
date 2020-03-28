//
//  EditToolRecordAudioViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/31.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

class EditToolRecordAudioViewController: EditToolBaseSettingsViewController {
    
    public var stopClosure: ((_ url: URL) -> Void)?
    
    private var isRecording = false
    
    private var audioRecorder: AudioRecorder?
    
    private var timer: Timer?
    
    private var recordTime: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        checkStatus()
        
        do {
            try audioRecorder = AudioRecorder()
        } catch {
            MessageBanner.error(content: "录音准备失败，当前无法录音")
            QELog(error)
        }
        
        waverView.recorder = audioRecorder?.recorder
    }
    
    override func operationDidFinish() {
        audioRecorder?.stop({ [weak self] (flag, url) in
            guard let strongSelf = self else { return }
            if flag {
                strongSelf.stopClosure?(url)
            } else {
                MessageBanner.error(content: "录音失败")
            }
        })
        navigationController?.popViewController()
    }
    
    override func backButtonTouchUpIndside() {
        audioRecorder?.stop({ (flag, url) in
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.removeItem(at: url)
                } catch {
                    QELog(error)
                }
            }
        })
        navigationController?.popViewController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    private func initView() {
        view.addSubview(waverView)
        view.addSubview(recordBackgroundView)
        recordBackgroundView.addSubview(recordStopView)
        recordBackgroundView.addSubview(recordStartView)
        view.addSubview(timerLabel)
        waverView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topBar.snp.bottom).offset(15)
            make.left.right.equalTo(self.view)
            make.height.equalTo(100)
        }
        recordBackgroundView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.timerLabel.snp.top).offset(-15)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        recordStopView.snp.makeConstraints { (make) in
            make.center.equalTo(self.recordBackgroundView)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        recordStartView.snp.makeConstraints { (make) in
            make.center.equalTo(self.recordBackgroundView)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        timerLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).offset(-15)
            make.centerX.equalTo(self.view)
        }
    }
    
    private func checkStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .denied, .restricted:
            MessageBanner.warning(content: "麦克风权限被拒绝，请在设置中打开")
            navigationController?.popViewController(animated: true)
        case .authorized:
            break
        case .notDetermined:
            requestMicroPhoneAuth()
        default:
            break
        }
    }
    
    private func requestMicroPhoneAuth() {
        AVCaptureDevice.requestAccess(for: .audio) { (granted) in
            if !granted {
                MessageBanner.warning(content: "麦克风权限被拒绝，请在设置中打开")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc
    private func didTapRecordView() {
        isRecording = !isRecording
        if isRecording {
            recordStartView.isHidden = true
            recordStopView.isHidden = false
            audioRecorder?.record()
            timer = Timer(timeInterval: 0.1, repeats: true, block: { [weak self] (timer) in
                guard let strongSelf = self else { return }
                strongSelf.recordTime += 0.1
                strongSelf.timerLabel.text = String(format: "%.1fs", strongSelf.recordTime)
            })
            RunLoop.current.add(timer!, forMode: .common)
        } else {
            recordStartView.isHidden = false
            recordStopView.isHidden = true
            audioRecorder?.pause()
            timer?.invalidate()
        }
    }
    
    private lazy var recordBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 30
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapRecordView))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var recordStopView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = UIColor.qe.hex(0xFA3E54)
        view.layer.cornerRadius = 2
        return view
    }()
    
    private lazy var recordStartView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xFA3E54)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var timerLabel: UILabel = {
        let view = UILabel()
        view.text = "0.0s"
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 13, weight: .light)
        return view
    }()
    
    private lazy var waverView: EditAudioWaverView = {
        let view = EditAudioWaverView()
        view.waveColor = UIColor.qe.hex(0xFA3E54)
        return view
    }()

}
