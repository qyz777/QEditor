//
//  EditToolService.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

fileprivate let BOX_SAMPLE_Width: CGFloat = 2

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
    
    public func loadAudioSamples(for size: CGSize, boxCount: Int, closure: @escaping((_ box: [[CGFloat]]) -> Void)) {
        guard videoModel != nil else {
            closure([])
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
                guard simpleData != nil else {
                    closure([])
                    return
                }
                let samples = self.filteredSamples(from: simpleData!, size: size)
                var sampleBox: [[CGFloat]] = []
                //1箱的宽度
                let boxWidth = Int(size.width / CGFloat(boxCount))
                for i in 0..<boxCount {
                    let box = Array(samples[i * boxWidth..<(i + 1) * boxWidth])
                    sampleBox.append(box)
                }
                DispatchQueue.main.sync {
                    closure(sampleBox)
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
    
    /// 过滤音频样本
    /// 数据分箱选出平均数
    /// 这里的粒度要控制好
    private func filteredSamples(from sampleData: Data, size: CGSize) -> [CGFloat] {
        var array: [UInt16] = []
        let sampleCount = sampleData.count / MemoryLayout<UInt16>.size
        let binSize = sampleCount / Int(size.width * BOX_SAMPLE_Width)
        let bytes: [UInt16] = sampleData.withUnsafeBytes( { bytes in
            let buffer: UnsafePointer<UInt16> = bytes.baseAddress!.assumingMemoryBound(to: UInt16.self)
            return Array(UnsafeBufferPointer(start: buffer, count: sampleData.count / MemoryLayout<UInt16>.size))
        })
        var maxSample: UInt16 = 0
        var i = 0
        while i < sampleCount - binSize {
            var sum: Int = 0
            //获取一箱的平均数，性能又好效果也好
            for j in 0..<binSize {
                sum += Int(bytes[i + j])
            }
            let value = sum / binSize
            array.append(UInt16(value))
            if value > maxSample {
                maxSample = UInt16(value)
            }
            i += binSize
        }
        let scaleFactor = size.height / CGFloat(maxSample)
        let res: [CGFloat] = array.map { (a) -> CGFloat in
            return CGFloat(a) * scaleFactor
        }
        return res
    }
    
}
