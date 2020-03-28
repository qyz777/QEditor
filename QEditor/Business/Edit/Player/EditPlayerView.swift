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
    
    func playerSetupSyncLayer(_ player: EditPlayerView) -> CALayer?
    
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
    
    func playerSetupSyncLayer(_ player: EditPlayerView) -> CALayer? {
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
    
    /// 承接字幕的动画layer，在播放器的playView上
    public var animationLayer: CALayer?
    
    public private(set) var player = CompositionPlayer()
    
    public var playerView: CompositionPlayerView {
        return player.playerView
    }

    public init() {
        super.init(frame: .zero)
        addSubview(playerView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerView.frame = bounds
        animationLayer?.frame = playerView.frame
    }
    
    deinit {
        stop()
    }
    
    private func updateAnimationLayer() {
        animationLayer?.removeFromSuperlayer()
        animationLayer = CALayer()
        animationLayer?.frame = playerView.frame
        //设置speed为0，用timeOffset来控制动画
        animationLayer?.speed = 0
        if let syncLayer = delegate?.playerSetupSyncLayer(self) {
            animationLayer?.addSublayer(syncLayer)
        }
        layer.addSublayer(animationLayer!)
    }

}

//MARK: 播控
extension EditPlayerView {
    
    public func play() {
        guard status != .playing else {
            return
        }
        player.play()
        delegate?.player(self, statusDidChange: status)
    }
    
    public func stop() {
        guard status != .stop else {
            return
        }
        player.pause()
        delegate?.player(self, statusDidChange: status)
    }
    
    public func pause() {
        guard status != .pause else {
            return
        }
        player.pause()
        delegate?.player(self, statusDidChange: status)
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
                if Thread.isMainThread {
                    strongSelf.delegate?.player(strongSelf, didLoadVideoWith: strongSelf.duration)
                } else {
                    DispatchQueue.main.sync {
                        strongSelf.delegate?.player(strongSelf, didLoadVideoWith: strongSelf.duration)
                    }
                }
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
            //非主线程改此属性无效
            strongSelf.animationLayer?.timeOffset = time
            guard strongSelf.status == .playing else {
                return
            }
            strongSelf.delegate?.player(strongSelf, playAt: time)
        }
        player.finishedClosure = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.delegate?.playerDidPlayToEndTime(strongSelf)
        }
        updateAnimationLayer()
        player.updateAsset(asset, videoComposition: videoComposition, audioMix: audioMix)
    }
    
}
