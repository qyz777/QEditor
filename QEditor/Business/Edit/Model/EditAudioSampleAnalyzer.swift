//
//  EditAudioSampleAnalyzer.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/28.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

class EditAudioSampleAnalyzer {
    
    public func readAudioSamples(from asset: AVAsset, timeRange: CMTimeRange? = nil) -> Data? {
        let assetReader: AVAssetReader
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            QELog(error)
            return nil
        }
        if let timeRange = timeRange {
            assetReader.timeRange = timeRange
        }
        let track = asset.tracks(withMediaType: .audio).first!
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
    public func filteredSamples(from sampleData: Data, size: CGSize) -> [CGFloat] {
        var array: [UInt16] = []
        let sampleCount = sampleData.count / MemoryLayout<UInt16>.size
        let binSize = sampleCount / Int(size.width)
        let bytes = [UInt8](sampleData)
        var maxSample: UInt16 = 0
        var minSample: UInt16 = UInt16.max
        var i = 0
        while i < sampleCount - binSize {
            var sum: Int = 0
            //获取一箱的平均数，性能又好效果也好
            for j in 0..<binSize {
                sum += Int(bytes[i + j])
            }
            let value = sum / binSize
            array.append(UInt16(value))
            if value != 0 {
                maxSample = max(maxSample, UInt16(value))
                minSample = min(minSample, UInt16(value))
            }
            i += binSize
        }
        //min-max标准化
        let scales = array.map { (sample) -> Float in
            if sample == 0 {
                return 0
            }
            return Float((sample - minSample)) / Float((maxSample - minSample))
        }
        let res: [CGFloat] = scales.map { (s) -> CGFloat in
            return size.height / 2 * CGFloat(s)
        }
        return res
    }
    
}
