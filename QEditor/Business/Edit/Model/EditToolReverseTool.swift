//
//  EditToolReverseTool.swift
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

fileprivate let FRAMES_PER_SEC: Double = 25
fileprivate let FRAME_SCALE: CMTimeScale = 600
fileprivate let INCREMENT_TIME: Double = 1 / FRAMES_PER_SEC
fileprivate let MAX_READ_SAMPLE_COUNT = 50

fileprivate let SAVE_PATH = String.qe.documentPath() + "/ReverseVideos"

enum ReverseToolError: Error {
    case initWriterFailed
    case initInputFailed
    case initAdaptorFailed
}

class EditToolReverseTool {
    
    public var progress: Float = 0
    
    public var completionClosure: ((_ path: String) -> Void)?
    
    private var composition: AVMutableComposition?
    
    private let reverseTimeRange: CMTimeRange
    
    private var assetWriter: AVAssetWriter?
    
    private var assetWriterInput: AVAssetWriterInput?
    
    private var assetWriterPixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    
    private var timeElapsed: Double = 0
    
    private var outputPath = ""
    
    private var sampleBuffers: [CMSampleBuffer] = []
    
    private var tempVideoPaths: [String] = []
    
    init(with composition: AVMutableComposition, at timeRange: CMTimeRange) throws {
        self.composition = composition
        reverseTimeRange = timeRange
        let point = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        point.initialize(to: ObjCBool(true))
        if !FileManager.default.fileExists(atPath: SAVE_PATH, isDirectory: point) {
            try FileManager.default.createDirectory(atPath: SAVE_PATH, withIntermediateDirectories: true, attributes: nil)
        }
        
        let timestamp = String.qe.timestamp()
        outputPath = SAVE_PATH + "/" + timestamp + ".mov"
    }
    
    public func reverse() {
        DispatchQueue.global().async {
            QELog("开始反转视频")
            self.readImages()
        }
    }
    
    public func cancel() {
        assetWriter?.cancelWriting()
    }
    
    private func readImages() {
        do {
            try startWriting()
        } catch {
            QELog("start writing failed, reason: \(error.localizedDescription)")
            return
        }
        
        let track = composition!.tracks(withMediaType: .video).first!
        let reader: AVAssetReader
        do {
            reader = try AVAssetReader(asset: composition!)
        } catch {
            QELog("init reader failed, reason: \(error.localizedDescription)")
            return
        }
        reader.timeRange = reverseTimeRange
        let settings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: settings)
        reader.add(readerOutput)
        reader.startReading()
        while let sample = readerOutput.copyNextSampleBuffer() {
            autoreleasepool {
                sampleBuffers.append(sample)
            }
        }
        writeSample()
        reader.cancelReading()
        endWriting()
    }
    
    private func startWriting() throws {
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
        assetWriterInput!.markAsFinished()
        assetWriter!.finishWriting { [unowned self] in
            self.assetWriter = nil
            self.assetWriterInput = nil
            self.assetWriterPixelBufferAdaptor = nil
            self.sampleBuffers.removeAll()
            DispatchQueue.main.async {
                QELog("反转结束")
                self.composition = nil
                self.completionClosure?(self.outputPath)
            }
        }
    }
    
    private func writeSample() {
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
    }
    
}
