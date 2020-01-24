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
    
    public private(set) var videoModel: EditVideoModel?
    
    public private(set) var videoComposition: AVMutableVideoComposition?
    
    /// 供缩略图使用
    public private(set) var imageSourceComposition: AVMutableComposition?
    
    private var reverseTool: EditToolReverseTool?
    
    public let filterService = EditFilterService()
    
    public private(set) var segments: [EditCompositionSegment] = []

    public func splitTime() -> [CMTime] {
        guard videoModel != nil else {
            return []
        }

        let asset = videoModel!.composition
        let duration = Int(asset.duration.seconds)
        
        guard duration > 1 else {
            return []
        }

        var times: [CMTime] = []
        for i in 1...duration {
            let time = CMTime(seconds: Double(i), preferredTimescale: CMTimeScale(600))
            times.append(time)
        }
        return times
    }
    
    //MARK: Command
    public func excute(command: EditCommandKey, with context: EditCommandContext) {
        guard let type = registeredCommands[command] else {
            QELog("command unregistered!")
            return
        }
        guard let composition = videoModel?.composition else {
            return
        }
        let com = type.init()
        com.composition = composition
        com.videoComposition = videoComposition
        com.perform(context)
        videoModel?.composition = com.composition!
        videoComposition = com.videoComposition
    }
    
    //MARK: Filter
    public func adjustFilter(_ context: [String: (value: Float, range: CMTimeRange)]) {
        guard let composition = videoModel?.composition else {
            return
        }
        videoComposition = filterService.adjust(composition, with: context)
    }
    
    //MARK: Audio
    public func loadAudioSamples(for size: CGSize, boxCount: Int, width: CGFloat, closure: @escaping((_ box: [[CGFloat]]) -> Void)) {
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
    
    /// 生成partModel和videoModel
    /// 调用完此方法后所有视频model都使用videoModel
    public func generateVideoModel(from segments: [EditCompositionSegment]) {
        guard segments.count > 0 else {
            return
        }
        let composition = AVMutableComposition()
        imageSourceComposition = AVMutableComposition()
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let videoTrackA = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let videoTrackB = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let imageSourceTrack = imageSourceComposition!.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        //——  ——
        //  ——  ——
        //的方式插入到A B轨道中
        let tracks = [videoTrackA, videoTrackB]
        var cursorTime: CMTime = .zero
        var imageCursorTime: CMTime = .zero

        for i in 0..<segments.count {
            let trackIndex = i % 2
            let currentTrack = tracks[trackIndex]
            let asset = segments[i].asset
            let transitionDuration = CMTime(seconds: segments[i].transition.duration, preferredTimescale: 600)
            segments[i].videoTrackId = currentTrack.trackID
            var imageSourceRange = segments[i].timeRange
            if i + 1 < segments.count {
                imageSourceRange.duration -= transitionDuration
            }
            
            do {
                try currentTrack.insertTimeRange(segments[i].timeRange, of: asset.tracks(withMediaType: .video).first!, at: cursorTime)
                if let sourceAudioTrack = asset.tracks(withMediaType: .audio).first {
                    try audioTrack.insertTimeRange(segments[i].timeRange, of: sourceAudioTrack, at: cursorTime)
                }
                try imageSourceTrack.insertTimeRange(imageSourceRange, of: asset.tracks(withMediaType: .video).first!, at: imageCursorTime)
            } catch {
                QELog(error)
            }
            
            var timeRange = CMTimeRange(start: cursorTime, duration: segments[i].timeRange.duration)
            if i > 0 {
                timeRange.start += transitionDuration
                timeRange.duration -= transitionDuration
            }
            if i + 1 < segments.count {
                timeRange.duration -= transitionDuration
            }
            segments[i].rangeAtComposition = timeRange
            
            cursorTime += segments[i].timeRange.duration
            cursorTime -= transitionDuration
            imageCursorTime += imageSourceRange.duration
        }

        videoComposition = AVMutableVideoComposition(propertiesOf: composition)
        
//        for instruction in videoComposition!.instructions {
//            let ins = instruction as! AVMutableVideoCompositionInstruction
//            if ins.layerInstructions.count == 2 {
//                let layer = ins.layerInstructions[0] as! AVMutableVideoCompositionLayerInstruction
//                layer.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0, timeRange: ins.timeRange)
//            }
//        }
        
        setupTransition(segments.map({ (segment) -> EditTransitionModel in
            return segment.transition
        }))
        
        let formatTime = String.qe.formatTime(Int(composition.duration.seconds))
        videoModel = EditVideoModel(composition: composition, formatTime: formatTime)
    }
    
    //MARK: Private
    private func setupTransition(_ transitions: [EditTransitionModel]) {
        guard let videoComposition = videoComposition else {
            return
        }
        let instructions = EditTransitionInstructionBulder.buildInstructions(videoComposition: videoComposition, transitions: transitions)
        for instruction in instructions {
            let timeRange = instruction.compositionInstruction.timeRange
            let fromLayer = instruction.fromLayerInstruction
            let toLayer = instruction.toLayerInstruction
            switch instruction.transition.style {
            case .none:
                //啥也不干
                break
            case .fadeIn:
                toLayer?.setOpacityRamp(fromStartOpacity: 0.0, toEndOpacity: 1.0, timeRange: timeRange)
            case .fadeOut:
                fromLayer?.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0, timeRange: timeRange)
            }
//            if fromLayer != nil && toLayer != nil {
//                instruction.compositionInstruction.layerInstructions = [fromLayer!, toLayer!]
//            }
        }
    }
    
    private func resetVideoModel(_ composition: AVMutableComposition) {
        videoModel?.composition = composition
        videoModel?.formatTime = String.qe.formatTime(Int(composition.duration.seconds))
    }
    
    private func replaceSegment(_ segment: EditCompositionSegment, with asset: AVAsset) {
        let newSegment = EditCompositionSegment(asset: asset)
        var index = 0
        for i in 0..<segments.count {
            if segments[i].id == segment.id {
                index = i
                break
            }
        }
        segments.remove(at: index)
        segments.insert(newSegment, at: index)
        generateVideoModel(from: segments)
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
    
    private let registeredCommands: [EditCommandKey: EditCommand.Type] = [
        .rotate: EditRotateCommand.self,
        .mirror: EditMirrorCommand.self
    ]
    
}

//MARK: Edit

extension EditToolService {
    
    //MARK: Add Video
    public func addVideos(from segments: [EditCompositionSegment]) {
        self.segments.append(contentsOf: segments)
        generateVideoModel(from: self.segments)
    }
    
    //MARK: Remove Video
    public func removeVideo(for segment: EditCompositionSegment) {
        segments.removeAll { (s) -> Bool in
            return s.id == segment.id
        }
        generateVideoModel(from: segments)
    }
    
    //MARK: Split
    public func splitVideoAt(time: Double) {
        //传入了分割的时间点，需要重新处理一遍segments
        for i in 0..<segments.count {
            let segment = segments[i]
            let time = CMTime(seconds: time, preferredTimescale: 600)
            if time.between(segment.rangeAtComposition) {
                //找到要分割的段进行分割
                guard let url = segment.url else {
                    QELog("没找到合适的segment进行分割")
                    return
                }
                let newSegment = EditCompositionSegment(url: url)
                newSegment.timeRange = CMTimeRange(start: time, duration: segment.asset.duration - time)
                segment.removeAfterRangeAt(time: time)
                segments.insert(newSegment, at: i + 1)
                break
            }
        }
        generateVideoModel(from: segments)
    }
    
    //MARK: Change Speed
    public func changeSpeed(at segment: EditCompositionSegment, scale: Float) {
        guard let composition = videoModel?.composition else {
            return
        }
        let scaleDuration = segment.duration * Double(scale)
        let timeRange = segment.rangeAtComposition
        let toDuration = CMTime(seconds: scaleDuration, preferredTimescale: 600)
        //先拉伸track
        let videoTrack = composition.track(withTrackID: segment.videoTrackId)!
        let audioTrack = composition.tracks(withMediaType: .audio).first!
        videoTrack.scaleTimeRange(timeRange, toDuration: toDuration)
        audioTrack.scaleTimeRange(timeRange, toDuration: toDuration)
        //直接拉伸图片数据源轨道
        imageSourceComposition!.scaleTimeRange(timeRange, toDuration: toDuration)
        //再把数据源的range也拉伸
        segment.rangeAtComposition.duration = toDuration
        //重新生成videoComposition
        videoComposition = AVMutableVideoComposition(propertiesOf: composition)
    }
    
    //MARK: Reverse
    public func reverseVideo(at segment: EditCompositionSegment, closure: @escaping (_ error: Error?) -> Void) {
        guard let composition = videoModel?.composition else {
            return
        }
        do {
            reverseTool = try EditToolReverseTool(with: composition.mutableCopy() as! AVMutableComposition, at: segment.rangeAtComposition)
        } catch {
            closure(error)
            return
        }
        reverseTool!.completionClosure = { [unowned self] (asset, error) in
            if let asset = asset {
                self.replaceSegment(segment, with: asset)
                closure(nil)
            } else if let error = error {
                closure(error)
            }
            self.reverseTool = nil
        }
        reverseTool!.reverse()
    }
    
    //MARK: Transition
    public func addTransition(_ transition: EditTransitionModel, at index: Int) {
        guard 0 <= index && index < segments.count else {
            QELog("转场特效添加错误!")
            return
        }
        segments[index].transition = transition
        generateVideoModel(from: segments)
    }
    
}

//MARK: 废弃的方法
//    public func generateVideoModel(from segments: [EditCompositionSegment]) {
//        guard segments.count > 0 else {
//            return
//        }
//        let composition = AVMutableComposition()
//        imageSourceComposition = AVMutableComposition()
//        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
//        let videoTrackA = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
//        let videoTrackB = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
//        let imageSourceTrack = imageSourceComposition!.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
//
//        var passThroughTimeRanges: [CMTimeRange] = []
//        var transitionTimeRanges: [CMTimeRange] = []
//
//        var maxWidth = CGFloat.zero
//        var maxHeight = CGFloat.zero
//
//        let tracks = [videoTrackA, videoTrackB]
//        let transitionDuration = CMTime(seconds: 1, preferredTimescale: 600)
//        var cursorTime: CMTime = .zero
//        var imageCursorTime: CMTime = .zero
//
//        for i in 0..<segments.count {
//            let trackIndex = i % 2
//            let currentTrack = tracks[trackIndex]
//            let asset = segments[i].asset
//            var imageSourceRange = segments[i].timeRange
//            if i + 1 < segments.count {
//                imageSourceRange.duration -= transitionDuration
//            }
//
//            do {
//                try currentTrack.insertTimeRange(segments[i].timeRange, of: asset.tracks(withMediaType: .video).first!, at: cursorTime)
//                try audioTrack.insertTimeRange(segments[i].timeRange, of: asset.tracks(withMediaType: .audio).first!, at: cursorTime)
//                try imageSourceTrack.insertTimeRange(imageSourceRange, of: asset.tracks(withMediaType: .video).first!, at: imageCursorTime)
//            } catch {
//                QELog(error)
//            }
//
//            let videoSourveTrack = asset.tracks(withMediaType: .video).first!
//            maxWidth = max(videoSourveTrack.naturalSize.width, maxWidth)
//            maxHeight = max(videoSourveTrack.naturalSize.height, maxHeight)
//
//            var timeRange = CMTimeRange(start: cursorTime, duration: segments[i].timeRange.duration)
//            if i > 0 {
//                timeRange.start += transitionDuration
//                timeRange.duration -= transitionDuration
//            }
//            if i + 1 < segments.count {
//                timeRange.duration -= transitionDuration
//            }
//            passThroughTimeRanges.append(timeRange)
//            segments[i].rangeAtComposition = timeRange
//
//            cursorTime += segments[i].timeRange.duration
//            cursorTime -= transitionDuration
//            imageCursorTime += imageSourceRange.duration
//
//            if i + 1 < segments.count {
//                transitionTimeRanges.append(CMTimeRange(start: cursorTime, duration: transitionDuration))
//            }
//        }
//
//        var compositionInstructions: [AVMutableVideoCompositionInstruction] = []
//        for i in 0..<segments.count {
//            let trackIndex = i % 2
//            let currentTrack = tracks[trackIndex]
//            let instruction = AVMutableVideoCompositionInstruction()
//            instruction.timeRange = passThroughTimeRanges[i]
//            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: currentTrack)
//            instruction.layerInstructions = [layerInstruction]
//            compositionInstructions.append(instruction)
//            if i + 1 < segments.count {
//                let foregroundTrack = tracks[trackIndex]
//                let backgroundTrack = tracks[1 - trackIndex]
//                let instruction = AVMutableVideoCompositionInstruction()
//                let timeRange = transitionTimeRanges[i]
//                instruction.timeRange = timeRange
//                let fromLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: foregroundTrack)
//                let toLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: backgroundTrack)
//                //todo:暂时设一个溶解效果
//                toLayerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0, timeRange: timeRange)
//                instruction.layerInstructions = [fromLayerInstruction, toLayerInstruction]
//                compositionInstructions.append(instruction)
//            }
//        }
//
//        var lastTimeDuration = CMTime.zero
//        for i in 0..<segments.count {
//            if i < segments.count - 1 {
//                lastTimeDuration += transitionDuration
//            }
//        }
//
//        let instruction = AVMutableVideoCompositionInstruction()
//        instruction.timeRange = CMTimeRange(start: cursorTime + transitionDuration, duration: lastTimeDuration)
//        compositionInstructions.append(instruction)
//
//        videoComposition = AVMutableVideoComposition()
//        videoComposition?.instructions = compositionInstructions
//        videoComposition?.renderSize = CGSize(width: maxWidth, height: maxHeight)
//        videoComposition?.frameDuration = CMTime(value: 1, timescale: 30)
//
//        let formatTime = String.qe.formatTime(Int(composition.duration.seconds))
//        videoModel = EditVideoModel(composition: composition, formatTime: formatTime)
//    }
