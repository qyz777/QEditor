//
//  PlayerView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/13.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation
import KVOController

public enum PlayerViewStatus {
    case playing
    case pause
    case stop
    case error
}

public protocol PlayerViewDelegate: class {
    
    func player(_ player: PlayerView, didChange status: AVPlayerItem.Status)
    
    func player(_ player: PlayerView, playAt time: Double)
    
    func player(_ player: PlayerView, didLoadVideoWith duration: Int64)
    
    func player(_ player: PlayerView, loadVideoFailWith error: String)
    
    func player(_ player: PlayerView, statusDidChange status: PlayerViewStatus)
    
    func playerDidPlayToEndTime(_ player: PlayerView)
    
}

extension PlayerViewDelegate {
    
    func player(_ player: PlayerView, loadVideoFailWith error: String) {}
    
    func player(_ player: PlayerView, statusDidChange status: PlayerViewStatus) {}
    
    func playerDidPlayToEndTime(_ player: PlayerView) {}
    
}

public class PlayerView: UIView {
    
    public weak var delegate: PlayerViewDelegate?
    
    public var status: PlayerViewStatus = .stop
    
    private var timeObserver: Any?
    
    private var currentItem: AVPlayerItem?

    public init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
    
    public override var debugDescription: String {
        if currentItem != nil && currentItem!.error != nil {
            return currentItem!.error!.localizedDescription
        }
        return ""
    }
    
    @objc
    func playerItemDidPlayToEndTime() {
        status = .pause
        delegate?.player(self, statusDidChange: status)
        delegate?.playerDidPlayToEndTime(self)
    }
    
    lazy var player: AVPlayer = {
        return AVPlayer()
    }()
    
    lazy var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: player)
        self.layer.addSublayer(layer)
        return layer
    }()

}

public extension PlayerView {
    
    func play() {
        guard currentItem != nil && timeObserver != nil else {
            return
        }
        guard status == .stop || status == .pause else {
            return
        }
        player.play()
        status = .playing
        delegate?.player(self, statusDidChange: status)
    }
    
    func stop() {
        player.pause()
        if timeObserver != nil {
            player.removeTimeObserver(timeObserver!)
            timeObserver = nil
        }
        status = .stop
        delegate?.player(self, statusDidChange: status)
    }
    
    func pause() {
        player.pause()
        status = .pause
        delegate?.player(self, statusDidChange: status)
    }
    
    func seek(to time: Double) {
        guard currentItem != nil else {
            return
        }
        let time = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func setupPlayer(with url: URL) {
        let asset = AVURLAsset(url: url)
        currentItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: currentItem)
        if timeObserver == nil {
            let interval = CMTime(seconds: 0.05, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
                if let strongSelf = self {
                    strongSelf.delegate?.player(strongSelf, playAt: time.seconds)
                }
            }
        }
        kvoControllerNonRetaining.observe(currentItem!, keyPath: "status", options: [.initial, .new]) { [weak self] (_, _, change) in
            let status = AVPlayerItem.Status(rawValue: (change["new"] as! NSNumber).intValue)!
            if let strongSelf = self {
                //转发播放器状态出去
                strongSelf.delegate?.player(strongSelf, didChange: status)
                if status == .readyToPlay {
                    //转发视频时间出去
                    let duration = Int64(strongSelf.currentItem!.asset.duration.seconds)
                    strongSelf.delegate?.player(strongSelf, didLoadVideoWith: duration)
                } else if status == .failed || status == .unknown {
                    strongSelf.delegate?.player(strongSelf, loadVideoFailWith: strongSelf.currentItem!.error?.localizedDescription ?? "")
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
}
