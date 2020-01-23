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
    
    public var videoTrackId: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    public let id: Int
    
    public let asset: AVAsset
    
    public let url: URL?
    
    public var duration: Double {
        return timeRange.duration.seconds
    }
    
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
    
    public func removeAfterRangeAt(time: CMTime) {
        timeRange = CMTimeRange(start: timeRange.start, duration: time)
    }
    
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
