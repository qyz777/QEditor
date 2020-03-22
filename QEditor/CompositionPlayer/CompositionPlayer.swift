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
    
    /// The status is indeterminate before asset is set
    case indeterminate
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
    
    public private(set) var status: CompositionPlayerStatus = .indeterminate {
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
    
    /// Add filters to this array and call updateAsset(_:) method
    public var filters: [BasicOperation] = []
    
    private var movie: MovieInput?
    
    private var speaker: SpeakerOutput?
    
    public init(asset: AVAsset, videoComposition: AVVideoComposition? = nil) {
        playerView.renderView = renderView
        updateAsset(asset, videoComposition: videoComposition)
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
            strongSelf.playbackTime = (movie.currentTime?.seconds) ?? 0
        }
        movie.completion = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.status = .stop
        }
        speaker = SpeakerOutput()
        movie.audioEncodingTarget = speaker
        
        applyFilters(filters)
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
    
    public func appendFilter(_ filter: BasicOperation) {
        filters.append(filter)
    }
    
    public func removeAllFilters() {
        filters.removeAll()
    }
    
    public func applyFilter(_ filter: BasicOperation) {
        guard movie != nil else { return }
        applyFilters([filter])
    }
    
    public func applyFilters(_ filters: [BasicOperation]) {
        guard let movie = movie else { return }
        self.filters = filters
        movie.removeAllTargets()
        var currentTarget: ImageSource = movie
        filters.forEach {
            currentTarget.addTarget($0)
            currentTarget = $0
        }
        currentTarget.addTarget(renderView)
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        renderView?.frame = bounds
    }
    
}
