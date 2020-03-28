//
//  EditPlayerView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/21.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

public protocol EditPlayerViewDelegate: class {
    
    func player(_ player: EditPlayerView, playAt time: Double)
    
    func player(_ player: EditPlayerView, didLoadVideoWith duration: Double)
    
    func player(_ player: EditPlayerView, statusDidChange status: PlayerViewStatus)
    
    func playerDidPlayToEndTime(_ player: EditPlayerView)
    
    func playerVideoComposition(_ player: EditPlayerView) -> AVMutableVideoComposition?
    
    func playerAudioMix(_ player: EditPlayerView) -> AVAudioMix?
    
}

extension EditPlayerViewDelegate {
    
    func player(_ player: EditPlayerView, statusDidChange status: PlayerViewStatus) {}
    
    func playerDidPlayToEndTime(_ player: EditPlayerView) {}
    
    func playerVideoComposition(_ player: EditPlayerView) -> AVMutableVideoComposition? {
        return nil
    }
    
    func playerAudioMix(_ player: EditPlayerView) -> AVAudioMix? {
        return nil
    }
    
}

public class EditPlayerView: UIView {

    public weak var delegate: EditPlayerViewDelegate?
    
    public var status: PlayerViewStatus = .unknown
    
    public var playbackTime: TimeInterval {
        return player.playbackTime
    }
    
    public var duration: TimeInterval {
        return player.duration
    }
    
    public let player: CompositionPlayer
    
    public var playerView: CompositionPlayerView {
        return player.playerView
    }

    public init(player: CompositionPlayer) {
        self.player = player
        super.init(frame: .zero)
        addSubview(playerView)
    }
    
    required init?(coder: NSCoder) {
        self.player = CompositionPlayer()
        super.init(coder: coder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerView.frame = bounds
    }
    
    deinit {
        stop()
    }

}

//MARK: 播控
extension EditPlayerView {
    
    public func play() {
        player.play()
    }
    
    public func stop() {
        player.pause()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func seek(to time: Double) {
        let time = CMTime(seconds: time, preferredTimescale: CMTimeScale(600))
        player.seek(to: time)
    }
    
}

//MARK: 数据源
extension EditPlayerView {
    
    public func setup(url: URL) {
        let asset = AVURLAsset(url: url)
        setup(asset: asset)
    }
    
    public func setup(asset: AVAsset) {
        let videoComposition = delegate?.playerVideoComposition(self)
        let audioMix = delegate?.playerAudioMix(self)
        player.assetLoadClosure = { [weak self] (isReadyToPlay) in
            guard let strongSelf = self else { return }
            if isReadyToPlay {
                strongSelf.delegate?.player(strongSelf, didLoadVideoWith: strongSelf.duration)
            }
        }
        player.statusChangeClosure = { [weak self] (status) in
            guard let strongSelf = self else { return }
            switch status {
            case .indeterminate:
                strongSelf.status = .unknown
            case .error:
                strongSelf.status = .error
            case .pause:
                strongSelf.status = .pause
            case .playing:
                strongSelf.status = .playing
            case .stop:
                strongSelf.status = .stop
            }
            strongSelf.delegate?.player(strongSelf, statusDidChange: strongSelf.status)
        }
        player.playbackTimeChangeClosure = { [weak self] (time) in
            guard let strongSelf = self else { return }
            guard strongSelf.status == .playing else {
                return
            }
            strongSelf.delegate?.player(strongSelf, playAt: time)
        }
        player.finishedClosure = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.playerDidPlayToEndTime(strongSelf)
        }
        player.updateAsset(asset, videoComposition: videoComposition, audioMix: audioMix)
    }
    
}
