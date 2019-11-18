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
    
    public var videoPartModels: [EditVideoPartModel] = []
    
    public var videoModel: EditVideoModel?
    
    public var mediaModel: MediaVideoModel?
    
    private let editor = EditVideoEdtior()

    public func split() -> [CMTime] {
        guard videoModel != nil else {
            return []
        }

        let asset = videoModel!.composition
        let duration = Int(asset.duration.seconds)

        var times: [CMTime] = []
        for i in 1...duration {
            let time = CMTime(seconds: Double(i), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            times.append(time)
        }
        return times
    }
    
    /// 生成partModel和videoModel
    /// 调用完此方法后所有视频model都使用videoModel
    public func generateModels() {
        guard mediaModel != nil else {
            return
        }
        videoPartModels.removeAll()
        let partModel = EditVideoPartModel(beginTime: 0, endTime: mediaModel!.videoTime.seconds)
        videoPartModels.append(partModel)
        generateVideoModel()
    }
    
    public func generateModels(from videoParts: [EditVideoPartModel]) {
        videoPartModels = videoParts
        generateVideoModel()
    }
    
    private func generateVideoModel() {
        guard videoPartModels.count > 0 else {
            return
        }
        guard mediaModel != nil && mediaModel!.url != nil else {
            return
        }
        let mixComposition = AVMutableComposition()
        let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let asset = AVURLAsset(url: mediaModel!.url!)
        //修改方向
        let videoSourveTrack = asset.tracks(withMediaType: .video).first!
        videoTrack.preferredTransform = videoSourveTrack.preferredTransform
        
        var totalDutation: CMTime = .zero
        videoPartModels.forEach { (model) in
            let range = CMTimeRange(start: CMTime(seconds: model.beginTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), end: CMTime(seconds: model.endTime - model.beginTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            
            do {
                try insertAudioTrack(audioTrack, in: asset, with: range, at: totalDutation)
                try insertVideoTrack(videoTrack, in: asset, with: range, at: totalDutation)
            } catch {
                QELog(error)
            }
            
            let newDuration = CMTime(seconds: model.endTime - model.beginTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            totalDutation = CMTimeAdd(totalDutation, newDuration)
        }
        videoModel = EditVideoModel(composition: mixComposition, formatTime: mediaModel!.formatTime, url: mediaModel!.url!)
    }
    
    private func insertAudioTrack(_ track: AVMutableCompositionTrack, in asset: AVAsset, with timeRange: CMTimeRange, at startTime: CMTime) throws {
        guard let assetAudioTrack = asset.tracks(withMediaType: .audio).first else {
            return
        }
        try track.insertTimeRange(timeRange, of: assetAudioTrack, at: startTime)
    }
    
    private func insertVideoTrack(_ track: AVMutableCompositionTrack, in asset: AVAsset, with timeRange: CMTimeRange, at startTime: CMTime) throws {
        guard let assetVideoTrack = asset.tracks(withMediaType: .video).first else {
            return
        }
        try track.insertTimeRange(timeRange, of: assetVideoTrack, at: startTime)
    }
    
}
