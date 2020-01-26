//
//  EditCompositionVideoSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/26.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

class EditCompositionVideoSegment: EditCompositionSegment {
    
    var trackId: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    let id: Int
    
    let asset: AVAsset
    
    let url: URL?
    
    var duration: Double {
        return timeRange.duration.seconds
    }
    
    /// segment的转场动画模型
    var transition: EditTransitionModel = EditTransitionModel(duration: 0, style: .none)
    
    var rangeAtComposition: CMTimeRange = .zero
    
    var timeRange: CMTimeRange
    
    required init(url: URL) {
        self.url = url
        asset = AVURLAsset(url: url)
        timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        id = (url.absoluteString + String.qe.timestamp()).hashValue
    }
    
    required init(asset: AVAsset) {
        url = nil
        self.asset = asset
        timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        id = ("\(asset.duration.seconds)" + String.qe.timestamp()).hashValue
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
