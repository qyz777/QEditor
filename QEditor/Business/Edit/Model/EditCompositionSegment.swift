//
//  EditCompositionSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/21.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

class EditCompositionSegment {
    
    /// segment所在的视频trackId
    public var videoTrackId: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    /// segment的唯一标识符
    public let id: Int
    
    /// 资源数据源，可以是composition
    public let asset: AVAsset
    
    /// assert的url数据源，从asset初始化时为nil
    public let url: URL?
    
    public var duration: Double {
        return timeRange.duration.seconds
    }
    
    /// segment的转场动画模型
    public var transition: EditTransitionModel = EditTransitionModel(duration: 0, style: .none)
    
    /// 在composition中的timeRange
    public var rangeAtComposition: CMTimeRange = .zero
    
    /// 用来插入到composition的range
    public var timeRange: CMTimeRange
    
    public init(url: URL) {
        self.url = url
        asset = AVURLAsset(url: url)
        timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        id = (url.absoluteString + String.qe.timestamp()).hashValue
    }
    
    public init(asset: AVAsset) {
        url = nil
        self.asset = asset
        timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        id = ("\(asset.duration.seconds)" + String.qe.timestamp()).hashValue
    }
    
    /// 移除在time之后的用来插入composition的range
    /// - Parameter time: 移除时间点
    public func removeAfterRangeAt(time: CMTime) {
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
