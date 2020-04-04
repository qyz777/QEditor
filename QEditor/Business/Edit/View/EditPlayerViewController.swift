//
//  EditPlayerViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/13.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation


class EditPlayerViewController: UIViewController {
    
    public var presenter: (EditPlayerViewOutput)!
    
    public var okEditClosure: ((_ text: String) -> Void)?
    
    public var cancelEditClosure: (() -> Void)?
    
    private var duration: Double = 0
    
    var status: CompositionPlayerStatus = .unknow

    override public func viewDidLoad() {
        super.viewDidLoad()
        initView()
        timeLabel.text = String.qe.formatTime(0) + "/" + String.qe.formatTime(Int(duration))
    }
    
    private func initView() {
        view.backgroundColor = .black
        view.addSubview(playerView)
        view.addSubview(toolBar)
        view.addSubview(editView)
        toolBar.addSubview(playButton)
        toolBar.addSubview(timeLabel)
        
        playerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.toolBar.snp.top)
        }
        
        editView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.playerView).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        toolBar.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(44)
        }
        
        playButton.snp.makeConstraints { (make) in
            make.center.equalTo(self.toolBar)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(SCREEN_PADDING_X)
            make.centerY.equalTo(self.toolBar)
        }
    }
    
    @objc
    func didClickPlayButton() {
        if status == .playing {
            playButton.setImage(UIImage(named: "edit_play"), for: .normal)
            presenter.player.pause()
        } else {
            playButton.setImage(UIImage(named: "edit_pause"), for: .normal)
            presenter.player.play()
        }
    }
    
    lazy var playerView: EditPlayerView = {
        let view = EditPlayerView(player: presenter.player)
        return view
    }()
    
    lazy var toolBar: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_play"), for: .normal)
        view.addTarget(self, action: #selector(didClickPlayButton), for: .touchUpInside)
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = .systemFont(ofSize: 13)
        return view
    }()
    
    private lazy var editView: EditPlayerCaptionTextField = {
        let view = EditPlayerCaptionTextField()
        view.isHidden = true
        view.okClosure = { [unowned self, view] in
            view.resignFirstResponder()
            view.isHidden = true
            self.okEditClosure?(view.text ?? "")
            self.okEditClosure = nil
        }
        view.cancelClosure = { [unowned self, view] in
            view.resignFirstResponder()
            view.isHidden = true
            self.cancelEditClosure?()
            self.cancelEditClosure = nil
        }
        return view
    }()

}

extension EditPlayerViewController: EditPlayerViewInput {
    
    func updatePlayTime(_ time: Double) {
        let timeFormat = String.qe.formatTime(Int(time))
        timeLabel.text = "\(timeFormat)/" + String.qe.formatTime(Int(duration))
    }
    
    func updateDuration(_ duration: Double) {
        self.duration = duration
        timeLabel.text = String.qe.formatTime(0) + "/" + String.qe.formatTime(Int(duration))
    }
    
    func updatePlayViewStatus(_ status: CompositionPlayerStatus) {
        self.status = status
    }
    
    func playToEndTime() {
        playButton.setImage(UIImage(named: "edit_play"), for: .normal)
    }
    
    func showEditCaptionView(text: String?) {
        editView.isHidden = false
        editView.text = text
        editView.becomeFirstResponder()
    }
    
}
