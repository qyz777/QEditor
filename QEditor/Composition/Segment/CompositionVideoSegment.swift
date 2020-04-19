//
//  CompositionVideoSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/26.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

public class CompositionVideoSegment: CompositionMediaSegment {
    
    public var trackId: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    public let id: Int
    
    public let asset: AVAsset
    
    public let url: URL?
    
    public var duration: Double {
        return timeRange.duration.seconds
    }
    
    /// segment的转场动画模型
    public var transition: CompositionTransitionModel = CompositionTransitionModel(duration: 0, style: .none)
    
    public var rangeAtComposition: CMTimeRange = .zero
    
    public var timeRange: CMTimeRange
    
    public var isPrepare: Bool = false
    
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
        if let data = try? JSONEncoder().encode(transition), let transitionInfo = String(data: data, encoding: .utf8) {
            info["transition"] = transitionInfo
        }
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
        guard let transitionInfo = json["transition"] as? String else {
            throw SegmentCodableError.canNotFindTransition
        }
        guard let data = transitionInfo.data(using: .utf8) else {
            throw SegmentCodableError.canNotFindTransition
        }
        transition = try JSONDecoder().decode(CompositionTransitionModel.self, from: data)
    }
    
    public func prepare(_ closure: (() -> Void)?) {
        asset.loadValuesAsynchronously(forKeys: [AVAssetKey.tracks, AVAssetKey.duration, AVAssetKey.metadata]) { [unowned self] in
            let tracksStatus = self.asset.statusOfValue(forKey: AVAssetKey.tracks, error: nil)
            let durationStatus = self.asset.statusOfValue(forKey: AVAssetKey.duration, error: nil)
            self.isPrepare = tracksStatus == .loaded && durationStatus == .loaded
            closure?()
        }
    }
    
    /// 移除在time之后的用来插入composition的range
    /// - Parameter time: 移除时间点
    func removeAfterRangeAt(time: CMTime) {
        timeRange = CMTimeRange(start: timeRange.start, duration: time)
    }
    
    /// 第一祯图片
    lazy var thumbnail: UIImage? = {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            QELog(error)
        }
        return nil
    }()
    
}
