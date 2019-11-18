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
        toolView.presenter(self, playerDidChange: status)
        playerView.presenter(self, playerDidChange: status)
    }
    
    func player(_ player: PlayerView, playAt time: Double) {
        toolView.presenter(self, playerPlayAt: time)
        playerView.presenter(self, playerPlayAt: time)
    }
    
    public func player(_ player: PlayerView, didLoadVideoWith duration: Double) {
        toolView.presenter(self, playerDidLoadVideoWith: duration)
        playerView.presenter(self, playerDidLoadVideoWith: duration)
    }
    
    func player(_ player: PlayerView, statusDidChange status: PlayerViewStatus) {
        toolView.presenter(self, playerStatusDidChange: status)
        playerView.presenter(self, playerStatusDidChange: status)
    }
    
    func playerDidPlayToEndTime(_ player: PlayerView) {
        toolView.presenterPlayerDidEndToTime(self)
        playerView.presenterPlayerDidEndToTime(self)
    }
    
}

extension EditViewPresenter: EditPlayerViewOutput {
    
    
    
}
