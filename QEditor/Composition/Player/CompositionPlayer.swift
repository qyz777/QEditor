//
//  CompositionPlayer.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/21.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation
import GPUImage

public enum CompositionPlayerStatus {
    case playing
    case pause
    case stop
    case error
    
    /// The status is unknow before asset is set
    case unknow
}

public class CompositionPlayer {
    
    public private(set) var playbackTime: TimeInterval = 0 {
        willSet {
            playbackTimeChangeClosure?(newValue)
        }
    }
    
    public var playbackTimeChangeClosure: ((_ time: TimeInterval) -> Void)?
    
    public private(set) var asset: AVAsset?
    
    public var duration: TimeInterval {
        return asset?.duration.seconds ?? 0
    }
    
    public private(set) var playerView = CompositionPlayerView()
    
    public private(set) var status: CompositionPlayerStatus = .unknow {
        willSet {
            statusChangeClosure?(newValue)
        }
    }
    
    public var statusChangeClosure: ((_ status: CompositionPlayerStatus) -> Void)?
    
    public private(set) var isReadyToPlay = false {
        willSet {
            assetLoadClosure?(newValue)
        }
    }
    
    public var assetLoadClosure: ((_ isReadyToPlay: Bool) -> Void)?
    
    /// Called when video finished
    /// This closure will not called if isLoop is true
    public var finishedClosure: (() -> Void)?
    
    /// Set this attribute to true will print debug info
    public var enableDebug = false {
        willSet {
            movie?.runBenchmark = newValue
        }
    }
    
    /// Setting this attribute before the end of the video works
    public var isLoop = false {
        willSet {
            movie?.loop = newValue
        }
    }
    
    /// The player will control the animationLayer of animation with the property `timeOffset`
    /// You can set up some animations in this layer like caption
    public var animationLayer: CALayer? {
        willSet {
            //Set speed to 0, use timeOffset to control the animation
            newValue?.speed = 0
            playerView.animationLayer = newValue
            newValue?.timeOffset = playbackTime
        }
        didSet {
            oldValue?.removeFromSuperlayer()
        }
    }
    
    /// Add filters to this array and call updateAsset(_:) method
    public var filters: [CompositionFilter] = []
    
    private var movie: MovieInput?
    
    private var speaker: SpeakerOutput?
    
    public init(asset: AVAsset, videoComposition: AVVideoComposition? = nil, audioMix: AVAudioMix? = nil) {
        playerView.renderView = renderView
        updateAsset(asset, videoComposition: videoComposition, audioMix: audioMix)
    }
    
    public init() {
        playerView.renderView = renderView
    }
    
    deinit {
        stop()
        movie = nil
        speaker = nil
    }
    
    public func updateAsset(_ asset: AVAsset, videoComposition: AVVideoComposition? = nil, audioMix: AVAudioMix? = nil) {
        self.asset = asset
        isReadyToPlay = false
        asset.loadValuesAsynchronously(forKeys: ["tracks", "duration", "commonMetadata"]) { [weak self] in
            guard let strongSelf = self else { return }
            let tracksStatus = strongSelf.asset?.statusOfValue(forKey: AVAssetKey.tracks, error: nil) ?? .unknown
            let durationStatus = strongSelf.asset?.statusOfValue(forKey: AVAssetKey.duration, error: nil) ?? .unknown
            strongSelf.isReadyToPlay = tracksStatus == .loaded && durationStatus == .loaded
        }
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatLinearPCM
        ]
        do {
            movie = try MovieInput(asset: asset, videoComposition: videoComposition, audioMix: audioMix, playAtActualSpeed: true, loop: isLoop, audioSettings: audioSettings)
        } catch {
            status = .error
            if enableDebug {
                debugPrint(error)
            }
        }
        guard let movie = movie else { return }
        movie.progress = { [weak self, movie] (p) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.playbackTime = (movie.currentTime?.seconds) ?? 0
                //Non-main thread change this property is not valid
                strongSelf.animationLayer?.timeOffset = strongSelf.playbackTime
            }
        }
        movie.completion = { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.status = .stop
                strongSelf.finishedClosure?()
            }
        }
        speaker = SpeakerOutput()
        movie.audioEncodingTarget = speaker
        
        applyFilters()
    }
    
    private func applyFilters() {
        guard let movie = movie else { return }
        movie.removeAllTargets()
        var currentTarget: ImageSource = movie
        filters.forEach {
            guard let f = $0.instance() else { return }
            currentTarget.addTarget(f, atTargetIndex: 0)
            currentTarget = f
        }
        currentTarget.addTarget(renderView, atTargetIndex: 0)
    }
    
    private lazy var renderView: RenderView = {
        let view = RenderView(frame: UIScreen.main.bounds)
        return view
    }()
    
}

//MARK: Playback control
extension CompositionPlayer {
    
    public func play() {
        guard status != .playing else {
            return
        }
        movie?.start()
        speaker?.start()
        status = .playing
    }
    
    public func seek(to time: CMTime) {
        movie?.seek(to: time)
    }
    
    public func pause() {
        guard status != .pause else {
            return
        }
        movie?.pause()
        speaker?.cancel()
        status = .pause
    }
    
    public func stop() {
        guard status != .stop else {
            return
        }
        movie?.cancel()
        speaker?.cancel()
        status = .stop
    }
    
}


//MARK: Filter
extension CompositionPlayer {
    
    public func appendFilter(_ filter: CompositionFilter) {
        filters.append(filter)
    }
    
    public func removeAllFilters() {
        filters.removeAll()
    }
    
}

//MARK: CompositionPlayerView
public class CompositionPlayerView: UIView {
    
    public var renderView: RenderView? {
        willSet {
            guard let renderView = newValue else { return }
            addSubview(renderView)
        }
    }
    
    public var animationLayer: CALayer? {
        willSet {
            guard let animationLayer = newValue else { return }
            animationLayer.frame = bounds
            layer.insertSublayer(animationLayer, at: 99)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        renderView?.frame = bounds
        animationLayer?.frame = bounds
    }
    
}
