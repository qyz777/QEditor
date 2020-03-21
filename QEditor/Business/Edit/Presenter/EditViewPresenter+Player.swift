//
//  EditViewPresenter+Player.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

extension EditViewPresenter: PlayerViewDelegate {
    
    public func player(_ player: PlayerView, didChange status: AVPlayerItem.Status) {
        
    }
    
    func player(_ player: PlayerView, playAt time: Double) {
        toolView?.updatePlayTime(time)
        playerView?.updatePlayTime(time)
        addCaptionView?.updatePlayTime(time)
    }
    
    public func player(_ player: PlayerView, didLoadVideoWith duration: Double) {
        self.duration = duration
        toolView?.updateDuration(duration)
        playerView?.updateDuration(duration)
        addCaptionView?.updateDuration(duration)
    }
    
    func player(_ player: PlayerView, statusDidChange status: PlayerViewStatus) {
        playerStatus = status
        toolView?.updatePlayViewStatus(status)
        addCaptionView?.updatePlayViewStatus(status)
    }
    
    func playerDidPlayToEndTime(_ player: PlayerView) {
        playerView?.playToEndTime()
    }
    
    func playerVideoComposition(_ player: PlayerView) -> AVMutableVideoComposition? {
        return project.videoComposition
    }
    
    func playerAudioMix(_ player: PlayerView) -> AVAudioMix? {
        return project.audioMix
    }
    
    func playerSetupSyncLayer(_ player: PlayerView) -> CALayer? {
        return project.generateSyncLayer(with: player.bounds)
    }
    
}

extension EditViewPresenter: EditPlayerViewOutput {
    
    
    
}

extension EditViewPresenter: EditPlayerInteractionProtocol {
    
    func viewIsDraggingWith(with percent: Float) {
        playerView?.seek(to: percent)
    }
    
    func viewWillBeginDragging() {
        isPlayingBeforeDragging = playerStatus == .playing
        //开始拖动时暂停播放器
        playerView?.pause()
    }
    
    func viewDidEndDecelerating() {
        if isPlayingBeforeDragging {
            isPlayingBeforeDragging = false
            playerView?.play()
        }
    }
    
}
