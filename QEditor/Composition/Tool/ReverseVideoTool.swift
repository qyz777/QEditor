//
//  ReverseVideoTool.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/8.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//
//  反转视频的核心在于使用AVAssetReader读取每一帧
//  然后使用AVAssetWriterInputPixelBufferAdaptor填充每一帧
//  在使用AVAssetWriter写入到本地

import UIKit
import AVFoundation

fileprivate let FRAMES_PER_SEC: Double = 30
fileprivate let FRAME_SCALE: CMTimeScale = 600
//FPS
fileprivate let INCREMENT_TIME: Double = 1 / FRAMES_PER_SEC
fileprivate let MAX_READ_SAMPLE_COUNT = 50

fileprivate let SAVE_PATH = String.qe.documentPath() + "/ReverseVideos"

public enum ReverseToolError: Error {
    case initWriterFailed
    case initInputFailed
    case initAdaptorFailed
}

public class ReverseVideoTool {
    
    /// 此进度不是连续增长
    public var progress: Float = 0
    
    public var completionClosure: ((_ composition: AVMutableComposition?, _ error: Error?) -> Void)?
    
    private var composition: AVMutableComposition?
    
    private let reverseTimeRange: CMTimeRange
    
    private var assetWriter: AVAssetWriter?
    
    private var assetWriterInput: AVAssetWriterInput?
    
    private var assetWriterPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    private var sampleBuffers: [CMSampleBuffer] = []
    
    private var tempVideoPartPaths: [String] = []
    
    private var processedAssetTime: Double = 0
    
    private var incrementTime: Double = 0
    
    init(with composition: AVMutableComposition, at timeRange: CMTimeRange) throws {
        self.composition = composition
        reverseTimeRange = timeRange
        let point = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        point.initialize(to: ObjCBool(true))
        if !FileManager.default.fileExists(atPath: SAVE_PATH, isDirectory: point) {
            try FileManager.default.createDirectory(atPath: SAVE_PATH, withIntermediateDirectories: true, attributes: nil)
        }
        point.deinitialize(count: 1)
        point.deallocate()
    }
    
    public func reverse() {
        DispatchQueue.global().async {
            QELog("开始反转视频")
            self.readImages()
        }
    }
    
    public func cancel() {
        assetWriter?.cancelWriting()
        removeTempVideoParts()
        sampleBuffers.removeAll()
        progress = 0
    }
    
    private func readImages() {
        let track = composition!.tracks(withMediaType: .video).first!
        let reader: AVAssetReader
        do {
            reader = try AVAssetReader(asset: composition!)
        } catch {
            QELog("init reader failed, reason: \(error.localizedDescription)")
            completionClosure?(nil, error)
            return
        }
        reader.timeRange = reverseTimeRange
        let settings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        reader.add(readerOutput)
        reader.startReading()
        //读取每一帧
        while let sample = readerOutput.copyNextSampleBuffer() {
            sampleBuffers.append(sample)
            //分段加载
            if sampleBuffers.count >= MAX_READ_SAMPLE_COUNT {
                writeAsset()
            }
        }
        if sampleBuffers.count > 0 {
            writeAsset()
        }
        reader.cancelReading()
        //组合临时存储的asset
        let outputComposition = AVMutableComposition()
        var insertTime: CMTime = .zero
        while let path = tempVideoPartPaths.popLast() {
            let url = URL(fileURLWithPath: path)
            let options: [String: Any] = [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: true)]
            let asset = AVURLAsset(url: url, options: options)
            let timeRange = CMTimeRange(start: .zero, duration: asset.duration)
            do {
                try outputComposition.insertTimeRange(timeRange, of: asset, at: insertTime)
            } catch {
                QELog("merge assets failed, reason:\(error.localizedDescription)")
            }
            insertTime = CMTimeAdd(insertTime, asset.duration)
        }
        //清除临时视频片段
        removeTempVideoParts()
        progress = 1
        DispatchQueue.main.async {
            QELog("反转视频结束")
            self.completionClosure?(outputComposition, nil)
        }
    }
    
    private func startWriting() throws {
        let outputPath = SAVE_PATH + "/\(String.qe.timestamp())_\(arc4random()).mov"
        tempVideoPartPaths.append(outputPath)
        let outputURL = URL(fileURLWithPath: outputPath)
        assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
        guard assetWriter != nil else {
            throw ReverseToolError.initWriterFailed
        }
        let settings: [String: Any] = [AVVideoCodecKey: AVVideoCodecType.h264,
                                       AVVideoWidthKey: self.composition!.naturalSize.width,
                                       AVVideoHeightKey: self.composition!.naturalSize.height]
        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        guard assetWriterInput != nil else {
            throw ReverseToolError.initWriterFailed
        }
        assetWriterInput!.expectsMediaDataInRealTime = true
        assetWriter!.add(assetWriterInput!)
        assetWriterPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterInput!, sourcePixelBufferAttributes: nil)
        guard assetWriterPixelBufferAdaptor != nil else {
            throw ReverseToolError.initAdaptorFailed
        }
        assetWriter!.startWriting()
        assetWriter!.startSession(atSourceTime: CMTime(value: 0, timescale: FRAME_SCALE))
    }
    
    private func endWriting() {
        let semaphoe = DispatchSemaphore(value: 0)
        assetWriter?.finishWriting {
            semaphoe.signal()
        }
        semaphoe.wait()
    }
    
    private func writeSample() {
        var timeElapsed: Double = 0
        for i in (0..<sampleBuffers.count).reversed() {
            let sample = sampleBuffers[i]
            let pixelBuffer = CMSampleBufferGetImageBuffer(sample)
            let elapsedTime = timeElapsed
            let presentationTime = CMTime(value: CMTimeValue(elapsedTime * Double(FRAME_SCALE)), timescale: FRAME_SCALE)
            while !assetWriterInput!.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.1)
            }
            assetWriterPixelBufferAdaptor!.append(pixelBuffer!, withPresentationTime: presentationTime)
            timeElapsed += INCREMENT_TIME
        }
        processedAssetTime += timeElapsed
        progress = Float(processedAssetTime / reverseTimeRange.duration.seconds)
    }
    
    private func removeTempVideoParts() {
        tempVideoPartPaths.forEach {
            do {
                try FileManager.default.removeItem(atPath: $0)
            } catch {
                QELog(error.localizedDescription)
            }
        }
    }
    
    private func writeAsset() {
        do {
            try startWriting()
        } catch {
            QELog("start writing failed, reason: \(error.localizedDescription)")
            completionClosure?(nil, error)
            return
        }
        writeSample()
        endWriting()
        sampleBuffers.removeAll()
    }
    
}
