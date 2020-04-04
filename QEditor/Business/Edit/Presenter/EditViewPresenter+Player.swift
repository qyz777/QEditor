//
//  EditViewPresenter+Player.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

extension EditViewPresenter: EditPlayerViewOutput {}

extension EditViewPresenter: EditPlayerInteractionProtocol {
    
    func viewIsDraggingWith(with percent: Float) {
        seek(to: percent)
    }
    
    func viewWillBeginDragging() {
        isPlayingBeforeDragging = playerStatus == .playing
        //开始拖动时暂停播放器
        project.pause()
    }
    
    func viewDidEndDecelerating() {
        if isPlayingBeforeDragging {
            isPlayingBeforeDragging = false
            project.play()
        }
    }
    
    func seek(to percent: Float) {
        let time = duration * Double(percent)
        project.seek(to: time)
    }
    
}

extension EditViewPresenter {
    
    func setupPlayer() {
        project.player.assetLoadClosure = { [weak self] (isReadyToPlay) in
            guard let strongSelf = self else { return }
            if isReadyToPlay {
                strongSelf.toolView?.updateDuration(strongSelf.duration)
                strongSelf.playerView?.updateDuration(strongSelf.duration)
                strongSelf.addCaptionView?.updateDuration(strongSelf.duration)
            }
        }
        project.player.statusChangeClosure = { [weak self] (status) in
            guard let strongSelf = self else { return }
            strongSelf.playerStatus = status
            strongSelf.playerView?.updatePlayViewStatus(strongSelf.playerStatus)
            strongSelf.toolView?.updatePlayViewStatus(strongSelf.playerStatus)
            strongSelf.addCaptionView?.updatePlayViewStatus(strongSelf.playerStatus)
        }
        project.player.playbackTimeChangeClosure = { [weak self] (time) in
            guard let strongSelf = self else { return }
            strongSelf.playerView?.updatePlayTime(time)
            if strongSelf.project.player.status == .playing {
                strongSelf.toolView?.updatePlayTime(time)
                strongSelf.addCaptionView?.updatePlayTime(time)
            }
        }
        project.player.finishedClosure = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.playerView?.playToEndTime()
        }
    }
    
}
