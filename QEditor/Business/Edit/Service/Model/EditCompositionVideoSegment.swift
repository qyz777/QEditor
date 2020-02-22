//
//  EditCompositionVideoSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/26.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

public class EditCompositionVideoSegment: EditCompositionSegment {
    
    public var trackId: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    public let id: Int
    
    public let asset: AVAsset
    
    public let url: URL?
    
    public var duration: Double {
        return timeRange.duration.seconds
    }
    
    /// segment的转场动画模型
    public var transition: EditTransitionModel = EditTransitionModel(duration: 0, style: .none)
    
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
        url = nil
        self.asset = asset
        timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        id = ("\(asset.duration.seconds)" + String.qe.timestamp()).hashValue
        prepare(nil)
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
