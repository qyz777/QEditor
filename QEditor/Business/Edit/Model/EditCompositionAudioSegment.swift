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
    
    /// 加载音频样本
    /// - Parameters:
    ///   - size: 展示音频样本的视图size
    ///   - boxCount: 音频分箱数量
    ///   - width: 一箱对应的视图宽度
    ///   - closure: 数据回调
    func loadAudioSamples(for size: CGSize, boxCount: Int, width: CGFloat, closure: @escaping((_ box: [[CGFloat]]) -> Void)) {
        let key = "tracks"
        DispatchQueue.global().async {
            self.asset.loadValuesAsynchronously(forKeys: [key]) {
                let status = self.asset.statusOfValue(forKey: key, error: nil)
                var simpleData: Data? = nil
                if status == .loaded {
                    simpleData = self.readAudioSamples()
                }
                guard simpleData != nil else {
                    DispatchQueue.main.sync {
                        closure([])
                    }
                    return
                }
                let samples = self.filteredSamples(from: simpleData!, size: size, width: width)
                var sampleBox: [[CGFloat]] = []
                //1箱的宽度
                let boxWidth = Int(samples.count / boxCount)
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
    
    private func readAudioSamples() -> Data? {
        let assetReader: AVAssetReader
        do {
            assetReader = try AVAssetReader(asset: asset)
        } catch {
            QELog(error)
            return nil
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
    private func filteredSamples(from sampleData: Data, size: CGSize, width: CGFloat) -> [CGFloat] {
        var array: [UInt16] = []
        let sampleCount = sampleData.count / MemoryLayout<UInt16>.size
        let binSize = sampleCount / Int(size.width * width)
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
