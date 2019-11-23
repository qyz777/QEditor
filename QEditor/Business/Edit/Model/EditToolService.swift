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
    
    public func addVideos(from mediaModels: [MediaVideoModel]) {
        guard mediaModels.count > 0 && videoModel != nil else {
            return
        }
        var beginTime = videoPartModels.last!.endTime
        let composition = videoModel!.composition
        let videoTrack = composition.tracks(withMediaType: .video).first!
        let audioTrack = composition.tracks(withMediaType: .audio).first!
        var insertPoint = composition.duration
        mediaModels.forEach { (m) in
            let asset = AVURLAsset(url: m.url!)
            let endTime = beginTime + asset.duration.seconds
            let model = EditVideoPartModel(beginTime: beginTime, endTime: endTime)
            beginTime = endTime
            
            let range = CMTimeRange(start: .zero, end: asset.duration)
            do {
                try videoTrack.insertTimeRange(range, of: asset.tracks(withMediaType: .video).first!, at: insertPoint)
                try audioTrack.insertTimeRange(range, of: asset.tracks(withMediaType: .audio).first!, at: insertPoint)
            } catch {
                QELog(error)
            }
            videoPartModels.append(model)
            insertPoint = CMTimeAdd(insertPoint, asset.duration)
        }
        videoModel?.composition = composition
        videoModel?.formatTime = String.qe.formatTime(Int(composition.duration.seconds))
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
            let beginTime = model.beginTime
            let endTime = model.endTime
            let range = CMTimeRange(start: CMTime(seconds: beginTime, preferredTimescale: CMTimeScale(600)), end: CMTime(seconds: endTime, preferredTimescale: CMTimeScale(600)))
            
            do {
                try videoTrack.insertTimeRange(range, of: asset.tracks(withMediaType: .video).first!, at: totalDutation)
                try audioTrack.insertTimeRange(range, of: asset.tracks(withMediaType: .audio).first!, at: totalDutation)
            } catch {
                QELog(error)
            }
            
            let newDuration = CMTime(seconds: endTime - beginTime, preferredTimescale: CMTimeScale(600))
            totalDutation = CMTimeAdd(totalDutation, newDuration)
        }
        videoModel = EditVideoModel(composition: mixComposition, formatTime: mediaModel!.formatTime, url: mediaModel!.url!)
    }
    
}
