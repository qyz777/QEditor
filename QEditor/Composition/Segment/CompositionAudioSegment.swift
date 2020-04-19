//
//  CompositionAudioSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/26.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

public class CompositionAudioSegment: CompositionMediaSegment {
    
    public var trackId: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    public let id: Int
    
    public let asset: AVAsset
    
    public let url: URL?
    
    public var duration: Double {
        return timeRange.duration.seconds
    }
    
    public var rangeAtComposition: CMTimeRange = .zero
    
    public var timeRange: CMTimeRange
    
    public var isPrepare: Bool = false
    
    /// 是否读取所有音频参数
    public var isReadAllAudioSamples = false
    
    /// 声音
    public var volume: Float = 1
    
    /// 是否淡入
    public var isFadeIn: Bool = false
    
    /// 是否淡出
    public var isFadeOut: Bool = true
    
    /// 声音样式持续时间，预留设置，暂时为1.5
    public var styleDuration: Double = 1.5
    
    public var title: String?
    
    public var assetDuration: Double {
        return asset.duration.seconds
    }
    
    private let sampleAnalyzer = AudioSampleAnalyzer()
    
    required public init(url: URL) {
        self.url = url
        asset = AVURLAsset(url: url)
        timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        id = (url.absoluteString + String.qe.timestamp()).hashValue
        prepare(nil)
    }
    
    required public init(asset: AVAsset) {
        if let urlAsset = asset as? AVURLAsset {
            url = urlAsset.url
        } else {
            url = nil
        }
        self.asset = asset
        timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        id = ("\(asset.duration.seconds)" + String.qe.timestamp()).hashValue
        prepare(nil)
    }
    
    public func toJSON() -> [String : Any] {
        var info: [String: Any] = [:]
        if let url = url {
            info["url"] = url.path
        }
        info["start"] = rangeAtComposition.start.seconds
        info["end"] = rangeAtComposition.end.seconds
        if let title = title {
            info["title"] = title
        }
        info["fade_in"] = isFadeIn
        info["fade_out"] = isFadeOut
        info["volumn"] = volume
        return info
    }
    
    public required convenience init(json: [String : Any]) throws {
        guard let url = json["url"] as? String else {
            throw SegmentCodableError.canNotFindURL
        }
        self.init(url: URL(fileURLWithPath: url))
        guard let start = json["start"] as? Double else {
            throw SegmentCodableError.canNotFindRange
        }
        guard let end = json["end"] as? Double else {
            throw SegmentCodableError.canNotFindRange
        }
        rangeAtComposition = CMTimeRange(start: start, end: end)
        title = json["title"] as? String
        isFadeIn = (json["fade_in"] as? Bool) ?? false
        isFadeOut = (json["fade_out"] as? Bool) ?? true
        volume = (json["volumn"] as? Float) ?? 1.0
    }
    
    public func prepare(_ closure: (() -> Void)?) {
        asset.loadValuesAsynchronously(forKeys: [AVAssetKey.tracks, AVAssetKey.duration, AVAssetKey.metadata]) { [unowned self] in
            let tracksStatus = self.asset.statusOfValue(forKey: AVAssetKey.tracks, error: nil)
            let durationStatus = self.asset.statusOfValue(forKey: AVAssetKey.duration, error: nil)
            self.isPrepare = tracksStatus == .loaded && durationStatus == .loaded
            closure?()
        }
    }
    
    /// 加载音频样本
    /// - Parameters:
    ///   - size: 展示音频样本的视图size
    ///   - closure: 数据回调
    func loadAudioSamples(for size: CGSize, closure: @escaping((_ samples: [CGFloat]) -> Void)) {
        DispatchQueue.global().async {
            self.asset.loadValuesAsynchronously(forKeys: [AVAssetKey.tracks]) { [weak self] in
                guard let strongSelf = self else {
                    closure([])
                    return
                }
                let status = strongSelf.asset.statusOfValue(forKey: AVAssetKey.tracks, error: nil)
                var simpleData: Data? = nil
                if status == .loaded {
                    if strongSelf.isReadAllAudioSamples {
                        simpleData = strongSelf.sampleAnalyzer.readAudioSamples(from: strongSelf.asset)
                    } else {
                        simpleData = strongSelf.sampleAnalyzer.readAudioSamples(from: strongSelf.asset, timeRange: strongSelf.timeRange)
                    }
                }
                guard simpleData != nil else {
                    DispatchQueue.main.sync {
                        closure([])
                    }
                    return
                }
                let samples = strongSelf.sampleAnalyzer.filteredSamples(from: simpleData!, size: size)
                DispatchQueue.main.sync {
                    closure(samples)
                }
            }
        }
    }
    
}
