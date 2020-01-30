//
//  EditCompositionAudioSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/26.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

class EditCompositionAudioSegment: EditCompositionSegment {
    
    var trackId: CMPersistentTrackID = kCMPersistentTrackID_Invalid
    
    let id: Int
    
    let asset: AVAsset
    
    let url: URL?
    
    var duration: Double {
        return timeRange.duration.seconds
    }
    
    var rangeAtComposition: CMTimeRange = .zero
    
    var timeRange: CMTimeRange
    
    var isPrepare: Bool = false
    
    /// 是否读取所有音频参数
    var isReadAllAudioSamples = false
    
    /// 声音
    var volume: Float = 1
    
    /// 是否淡入
    var isFadeIn: Bool = false
    
    /// 是否淡出
    var isFadeOut: Bool = true
    
    /// 声音样式持续时间，预留设置，暂时为1.5
    var styleDuration: Double = 1.5
    
    var title: String?
    
    var assetDuration: Double {
        return asset.duration.seconds
    }
    
    private let sampleAnalyzer = EditAudioSampleAnalyzer()
    
    required init(url: URL) {
        self.url = url
        asset = AVURLAsset(url: url)
        timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        id = (url.absoluteString + String.qe.timestamp()).hashValue
        prepare(nil)
    }
    
    required init(asset: AVAsset) {
        url = nil
        self.asset = asset
        timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        id = ("\(asset.duration.seconds)" + String.qe.timestamp()).hashValue
        prepare(nil)
    }
    
    func prepare(_ closure: (() -> Void)?) {
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
