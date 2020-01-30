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
    
    public private(set) var audioMix: AVMutableAudioMix?
    
    private var reverseTool: EditToolReverseTool?
    
    public let filterService = EditFilterService()
    
    public private(set) var videoSegments: [EditCompositionVideoSegment] = []
    
    public private(set) var musicSegments: [EditCompositionAudioSegment] = []
    
    private let sampleAnalyzer = EditAudioSampleAnalyzer()

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
    public func addMusic(_ asset: AVAsset, at time: CMTime) -> EditCompositionAudioSegment? {
        guard let composition = videoModel?.composition else { return nil }
        let segment = EditCompositionAudioSegment(asset: asset)
        var nextSegment: EditCompositionAudioSegment?
        var index = 0
        var offset = composition.duration.seconds
        for i in 0..<musicSegments.count {
            let s = musicSegments[i]
            //校验添加的segment是否在别的segment段中
            if segment.rangeAtComposition.start.between(s.rangeAtComposition) {
                QELog("此位置不能插入音乐")
                return nil
            }
            //找到下一个segment
            if i + 1 < musicSegments.count {
                let ns = musicSegments[i + 1]
                let distance = ns.rangeAtComposition.start.seconds - time.seconds
                if 0 < distance && distance < offset {
                    offset = distance
                    nextSegment = ns
                    index = i
                }
            }
        }
        if nextSegment != nil {
            //如果有下一段segment，那么前一段最多与下一段连接
            let duration = nextSegment!.rangeAtComposition.start - time
            segment.timeRange = CMTimeRange(start: .zero, duration: duration)
            segment.rangeAtComposition = CMTimeRange(start: time, duration: duration)
        } else {
            //如果没有，直接插到结尾就完了
            let duration = composition.duration - time
            segment.timeRange = CMTimeRange(start: .zero, duration: duration)
            segment.rangeAtComposition = CMTimeRange(start: time, duration: duration)
        }
        musicSegments.insert(segment, at: index)
        //从新生成composition
        refreshComposition()
        return segment
    }
    
    /// 更新音乐片段数据源
    /// - Parameters:
    ///   - segment: 音乐片段数据源
    ///   - timeRange: 拖动后片段在轨道中的timeRange
    public func updateMusic(_ segment: EditCompositionAudioSegment, timeRange: CMTimeRange) {
        guard musicSegments.count > 0 else { return }
        guard let composition = videoModel?.composition else { return }
        //校验timeRange
        var timeRange = timeRange
        var preSegment: EditCompositionAudioSegment?
        var nextSegment: EditCompositionAudioSegment?
        var index = 0
        for i in 0..<musicSegments.count {
            let currentSegment = musicSegments[i]
            if currentSegment.id == segment.id {
                if i > 0 {
                    preSegment = musicSegments[i - 1]
                }
                if i + 1 < musicSegments.count {
                    nextSegment = musicSegments[i + 1]
                }
                index = i
                break
            }
        }
        if preSegment != nil && timeRange.start < preSegment!.rangeAtComposition.end {
            timeRange = CMTimeRange(start: preSegment!.rangeAtComposition.end, end: timeRange.end)
        } else if timeRange.start < .zero {
            timeRange = CMTimeRange(start: .zero, end: timeRange.end)
        }
        if nextSegment != nil && timeRange.end > nextSegment!.rangeAtComposition.start {
            timeRange = CMTimeRange(start: timeRange.start, end: nextSegment!.rangeAtComposition.start)
        } else if timeRange.end > composition.duration {
            timeRange = CMTimeRange(start: timeRange.start, end: composition.duration)
        }
        segment.rangeAtComposition = timeRange
        //修改在asset的timeRange，方式为左右扩张
        let halfSeconds = (segment.rangeAtComposition.duration - segment.timeRange.duration).seconds / 2
        if segment.timeRange.end.seconds + halfSeconds > segment.asset.duration.seconds {
            let offsetSeconds = segment.timeRange.end.seconds + halfSeconds - segment.asset.duration.seconds
            let newEnd = CMTime(seconds: segment.asset.duration.seconds, preferredTimescale: 600)
            let newStart = CMTime(seconds: segment.timeRange.start.seconds - halfSeconds - offsetSeconds, preferredTimescale: 600)
            segment.timeRange = CMTimeRange(start: newStart, duration: newEnd)
        } else if segment.timeRange.start.seconds - halfSeconds < 0 {
            let offsetSeconds = -(segment.timeRange.start.seconds - halfSeconds)
            let newEnd = CMTime(seconds: timeRange.start.seconds + halfSeconds + offsetSeconds, preferredTimescale: 600)
            segment.timeRange = CMTimeRange(start: .zero, duration: newEnd)
        } else {
            let newStart = CMTime(seconds: segment.timeRange.start.seconds - halfSeconds, preferredTimescale: 600)
            let newEnd = CMTime(seconds: segment.timeRange.end.seconds + halfSeconds, preferredTimescale: 600)
            segment.timeRange = CMTimeRange(start: newStart, end: newEnd)
        }
        musicSegments[index] = segment
        refreshComposition()
    }
    
    public func replaceMusic(oldSegment: EditCompositionAudioSegment, for newSegment: EditCompositionAudioSegment) {
        if newSegment.timeRange.duration < oldSegment.rangeAtComposition.duration {
            newSegment.rangeAtComposition = CMTimeRange(start: oldSegment.rangeAtComposition.start, duration: newSegment.timeRange.duration)
        } else {
            newSegment.rangeAtComposition = oldSegment.rangeAtComposition
            newSegment.timeRange = oldSegment.timeRange
        }
        newSegment.title = oldSegment.title
        for i in 0..<musicSegments.count {
            let segment = musicSegments[i]
            if segment.id == oldSegment.id {
                musicSegments[i] = newSegment
                break
            }
        }
        refreshComposition()
    }
    
    public func loadAudioSamples(for size: CGSize, boxCount: Int, closure: @escaping((_ box: [[CGFloat]]) -> Void)) {
        guard videoModel != nil else {
            closure([])
            return
        }
        let composition = videoModel!.composition
        DispatchQueue.global().async {
            composition.loadValuesAsynchronously(forKeys: [AVAssetKey.tracks]) { [weak self] in
                let status = composition.statusOfValue(forKey: AVAssetKey.tracks, error: nil)
                guard let strongSelf = self else {
                    closure([])
                    return
                }
                var simpleData: Data? = nil
                if status == .loaded {
                    simpleData = strongSelf.sampleAnalyzer.readAudioSamples(from: composition)
                }
                guard simpleData != nil else {
                    DispatchQueue.main.sync {
                        closure([])
                    }
                    return
                }
                let samples = strongSelf.sampleAnalyzer.filteredSamples(from: simpleData!, size: size)
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
    
    /// 生成composition
    /// 调用完此方法后所有视频model都使用videoModel
    public func refreshComposition() {
        guard videoSegments.count > 0 else {
            return
        }
        let composition = AVMutableComposition()
        imageSourceComposition = AVMutableComposition()
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let mixAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let videoTrackA = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let videoTrackB = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let imageSourceTrack = imageSourceComposition!.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        //——  ——
        //  ——  ——
        //的方式插入到A B轨道中
        let tracks = [videoTrackA, videoTrackB]
        var cursorTime: CMTime = .zero
        var imageCursorTime: CMTime = .zero

        for i in 0..<videoSegments.count {
            let trackIndex = i % 2
            let currentTrack = tracks[trackIndex]
            let asset = videoSegments[i].asset
            let transitionDuration = CMTime(seconds: videoSegments[i].transition.duration, preferredTimescale: 600)
            videoSegments[i].trackId = currentTrack.trackID
            var imageSourceRange = videoSegments[i].timeRange
            if i + 1 < videoSegments.count {
                imageSourceRange.duration -= transitionDuration
            }
            
            do {
                try currentTrack.insertTimeRange(videoSegments[i].timeRange, of: asset.tracks(withMediaType: .video).first!, at: cursorTime)
                if let sourceAudioTrack = asset.tracks(withMediaType: .audio).first {
                    try audioTrack.insertTimeRange(videoSegments[i].timeRange, of: sourceAudioTrack, at: cursorTime)
                }
                try imageSourceTrack.insertTimeRange(imageSourceRange, of: asset.tracks(withMediaType: .video).first!, at: imageCursorTime)
            } catch {
                QELog(error)
            }
            
            var timeRange = CMTimeRange(start: cursorTime, duration: videoSegments[i].timeRange.duration)
            if i > 0 {
                timeRange.start += transitionDuration
                timeRange.duration -= transitionDuration
            }
            if i + 1 < videoSegments.count {
                timeRange.duration -= transitionDuration
            }
            videoSegments[i].rangeAtComposition = timeRange
            
            cursorTime += videoSegments[i].timeRange.duration
            cursorTime -= transitionDuration
            imageCursorTime += imageSourceRange.duration
        }
        
        musicSegments.forEach {
            let asset = $0.asset
            guard let audioTrack = asset.tracks(withMediaType: .audio).first else { return }
            //这里跟插入视频不一样，这里是需要外面告诉segment插入在mixAudioTrack的哪个range里
            do {
                try mixAudioTrack.insertTimeRange($0.timeRange, of: audioTrack, at: $0.rangeAtComposition.start)
            } catch {
                QELog(error)
            }
        }

        videoComposition = AVMutableVideoComposition(propertiesOf: composition)
        
        setupTransition(videoSegments.map({ (segment) -> EditTransitionModel in
            return segment.transition
        }))
        
        setupAudioMix()
        
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
        }
    }
    
    private func setupAudioMix() {
        audioMix = AVMutableAudioMix()
        guard let composition = videoModel?.composition else { return }
        let mixAudioTrack = composition.tracks(withMediaType: .audio)[1]
        //设置混音
        //todo:原声的设置
        let param = AVMutableAudioMixInputParameters(track: mixAudioTrack)
        for segment in musicSegments {
            switch segment.style {
            case .none:
                param.setVolume(segment.volume, at: segment.rangeAtComposition.start)
            case .fadeIn:
                let duration = min(segment.styleDuration, segment.rangeAtComposition.duration.seconds)
                let newEnd = segment.rangeAtComposition.start + CMTime(seconds: duration, preferredTimescale: 600)
                let range = CMTimeRange(start: segment.rangeAtComposition.start, end: newEnd)
                param.setVolumeRamp(fromStartVolume: 0, toEndVolume: segment.volume, timeRange: range)
                param.setVolume(segment.volume, at: newEnd)
            case .fadeOut:
                let duration = min(segment.styleDuration, segment.rangeAtComposition.duration.seconds)
                let newStart = segment.rangeAtComposition.end - CMTime(seconds: duration, preferredTimescale: 600)
                let range = CMTimeRange(start: newStart, end: segment.rangeAtComposition.end)
                param.setVolume(segment.volume, at: segment.rangeAtComposition.start)
                param.setVolumeRamp(fromStartVolume: segment.volume, toEndVolume: 0, timeRange: range)
            }
        }
        audioMix!.inputParameters = [param]
    }
    
    private func replaceSegment(_ segment: EditCompositionVideoSegment, with asset: AVAsset) {
        let newSegment = EditCompositionVideoSegment(asset: asset)
        var index = 0
        for i in 0..<videoSegments.count {
            if videoSegments[i].id == segment.id {
                index = i
                break
            }
        }
        videoSegments.remove(at: index)
        videoSegments.insert(newSegment, at: index)
        refreshComposition()
    }
    
    private let registeredCommands: [EditCommandKey: EditCommand.Type] = [
        .rotate: EditRotateCommand.self,
        .mirror: EditMirrorCommand.self
    ]
    
}

//MARK: Edit

extension EditToolService {
    
    //MARK: Add Video
    public func addVideos(from segments: [EditCompositionVideoSegment]) {
        self.videoSegments.append(contentsOf: segments)
        refreshComposition()
    }
    
    //MARK: Remove Video
    public func removeVideo(for segment: EditCompositionVideoSegment) {
        videoSegments.removeAll { (s) -> Bool in
            return s.id == segment.id
        }
        refreshComposition()
    }
    
    //MARK: Split
    public func splitVideoAt(time: Double) {
        //传入了分割的时间点，需要重新处理一遍segments
        for i in 0..<videoSegments.count {
            let segment = videoSegments[i]
            let time = CMTime(seconds: time, preferredTimescale: 600)
            if time.between(segment.rangeAtComposition) {
                //找到要分割的段进行分割
                guard let url = segment.url else {
                    QELog("没找到合适的segment进行分割")
                    return
                }
                let newSegment = EditCompositionVideoSegment(url: url)
                newSegment.timeRange = CMTimeRange(start: time, duration: segment.asset.duration - time)
                segment.removeAfterRangeAt(time: time)
                videoSegments.insert(newSegment, at: i + 1)
                break
            }
        }
        refreshComposition()
    }
    
    //MARK: Change Speed
    public func changeSpeed(at segment: EditCompositionVideoSegment, scale: Float) {
        guard let composition = videoModel?.composition else {
            return
        }
        let scaleDuration = segment.duration * Double(scale)
        let timeRange = segment.rangeAtComposition
        let toDuration = CMTime(seconds: scaleDuration, preferredTimescale: 600)
        //先拉伸track
        let videoTrack = composition.track(withTrackID: segment.trackId)!
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
    public func reverseVideo(at segment: EditCompositionVideoSegment, closure: @escaping (_ error: Error?) -> Void) {
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
        guard 0 <= index && index < videoSegments.count else {
            QELog("转场特效添加错误!")
            return
        }
        videoSegments[index].transition = transition
        refreshComposition()
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
