//
//  EditToolService.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

class EditToolService {
    
    public var videoModel: EditVideoModel?

    public func split() -> [CMTime] {
        guard videoModel != nil else {
            return []
        }

        let asset = videoModel!.composition
        let duration = Int(asset.duration.seconds)

        var times: [CMTime] = []
        for i in 1...duration {
            let time = CMTime(seconds: Double(i), preferredTimescale: CMTimeScale(600))
            times.append(time)
        }
        return times
    }
    
    public func addVideos(from mediaModels: [MediaVideoModel]) {
        guard mediaModels.count > 0 && videoModel != nil else {
            return
        }
        var beginTime = videoModel!.composition.duration.seconds
        let composition = videoModel!.composition
        let videoTrack = composition.tracks(withMediaType: .video).first!
        let audioTrack = composition.tracks(withMediaType: .audio).first!
        var insertPoint = composition.duration
        mediaModels.forEach { (m) in
            let asset = AVURLAsset(url: m.url!)
            let endTime = beginTime + asset.duration.seconds
            beginTime = endTime
            
            let range = CMTimeRange(start: .zero, end: asset.duration)
            do {
                try videoTrack.insertTimeRange(range, of: asset.tracks(withMediaType: .video).first!, at: insertPoint)
                try audioTrack.insertTimeRange(range, of: asset.tracks(withMediaType: .audio).first!, at: insertPoint)
            } catch {
                QELog(error)
            }
            insertPoint = CMTimeAdd(insertPoint, asset.duration)
        }
        resetVideoModel(composition)
    }
    
    public func removeVideoTimeRange(_ range: CMTimeRange) {
        guard videoModel != nil else {
            return
        }
        let composition = videoModel!.composition
        composition.removeTimeRange(range)
        resetVideoModel(composition)
    }
    
    /// 生成partModel和videoModel
    /// 调用完此方法后所有视频model都使用videoModel
    public func generateVideoModel(from assets: [AVAsset]) {
        let composition = AVMutableComposition()
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        var insertPoint: CMTime = .zero
        assets.forEach { (asset) in
            //修改方向
            let videoSourveTrack = asset.tracks(withMediaType: .video).first!
            videoTrack.preferredTransform = videoSourveTrack.preferredTransform
            let range = CMTimeRange(start: .zero, end: asset.duration)
            
            do {
                try videoTrack.insertTimeRange(range, of: asset.tracks(withMediaType: .video).first!, at: insertPoint)
                try audioTrack.insertTimeRange(range, of: asset.tracks(withMediaType: .audio).first!, at: insertPoint)
            } catch {
                QELog(error)
            }
            
            insertPoint = CMTimeAdd(insertPoint, asset.duration)
        }
        
        let formatTime = String.qe.formatTime(Int(composition.duration.seconds))
        videoModel = EditVideoModel(composition: composition, formatTime: formatTime)
    }
    
    private func resetVideoModel(_ composition: AVMutableComposition) {
        videoModel?.composition = composition
        videoModel?.formatTime = String.qe.formatTime(Int(composition.duration.seconds))
    }
    
}
