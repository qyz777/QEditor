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
    
    public func loadAudioSamples(closure: @escaping((_ data: Data?) -> Void)) {
        guard videoModel != nil else {
            closure(nil)
            return
        }
        let composition = videoModel!.composition
        let key = "tracks"
        DispatchQueue.global().async {
            composition.loadValuesAsynchronously(forKeys: [key]) {
                let status = composition.statusOfValue(forKey: key, error: nil)
                var simpleData: Data? = nil
                if status == .loaded {
                    simpleData = self.readAudioSamples()
                }
                DispatchQueue.main.sync {
                    closure(simpleData)
                }
            }
        }
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
    
    private func readAudioSamples() -> Data? {
        guard videoModel != nil else {
            return nil
        }
        let composition = videoModel!.composition
        let assetReader: AVAssetReader
        do {
            assetReader = try AVAssetReader(asset: composition)
        } catch {
            QELog(error)
            return nil
        }
        let track = composition.tracks(withMediaType: .audio).first!
        let settings: [String : Any] = [AVFormatIDKey: kAudioFormatLinearPCM,
                                        AVLinearPCMIsBigEndianKey: false,
                                        AVLinearPCMIsFloatKey: false,
                                        AVLinearPCMBitDepthKey: 16]
        let trackOutput = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        assetReader.add(trackOutput)
        assetReader.startReading()
        
        var sampleData = Data()
        while assetReader.status == .reading {
            let sampleBuffer = trackOutput.copyNextSampleBuffer()
            if sampleBuffer != nil {
                let blockBufferRef = CMSampleBufferGetDataBuffer(sampleBuffer!)
                let length = CMBlockBufferGetDataLength(blockBufferRef!)
                let sampleBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: length)
                CMBlockBufferCopyDataBytes(blockBufferRef!, atOffset: 0, dataLength: length, destination: sampleBytes)
                let ptr = UnsafePointer(sampleBytes)
                sampleData.append(ptr, count: length)
                CMSampleBufferInvalidate(sampleBuffer!)
            }
        }
        if assetReader.status == .completed {
            return sampleData
        } else {
            QELog("Failed to read audio samples from asset.")
            return nil
        }
    }
    
}
