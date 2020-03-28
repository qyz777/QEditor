//
//  CompositionProject.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/21.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  
//  剪辑Service层，提供各个剪辑功能接口
//  fps -> 帧率 每秒的帧数
//  总帧数 = 总时间 * fps

import Foundation
import AVFoundation
import GPUImage

public class CompositionProject {
    
    public private(set) var composition: AVMutableComposition?
    
    public private(set) var videoComposition: AVMutableVideoComposition?
    
    /// 供缩略图使用
    public private(set) var imageSourceComposition: AVMutableComposition?
    
    public private(set) var audioMix: AVMutableAudioMix?
    
    private var reverseTool: ReverseVideoTool?
    
    public private(set) var videoSegments: [CompositionVideoSegment] = []
    
    public private(set) var musicSegments: [CompositionAudioSegment] = []
    
    public private(set) var recordAudioSegments: [CompositionAudioSegment] = []
    
    public private(set) var captionSegments: [CompositionCaptionSegment] = []
    
    public var selectedFilter: CompositionFilter = .none
    
    /// Output player of project
    public let player = CompositionPlayer()
    
    //MARK: Composition
    /// 刷新composition
    public func refreshComposition() {
        guard videoSegments.count > 0 else {
            return
        }
        let composition = AVMutableComposition()
        imageSourceComposition = AVMutableComposition()
        
        if videoSegments.count > 1 {
            setupMixVideoTrackComposition(composition)
        } else {
            setupSingleVideoTrackComposition(composition)
        }
        
        if musicSegments.count > 0 {
            let musicAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            musicSegments.forEach {
                let asset = $0.asset
                guard let audioTrack = asset.tracks(withMediaType: .audio).first else { return }
                //这里跟插入视频不一样，这里是需要外面告诉segment插入在mixAudioTrack的哪个range里
                do {
                    try musicAudioTrack.insertTimeRange($0.timeRange, of: audioTrack, at: $0.rangeAtComposition.start)
                } catch {
                    QELog(error)
                }
            }
        }
        
        if recordAudioSegments.count > 0 {
            let recordAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            recordAudioSegments.forEach {
                let asset = $0.asset
                guard let audioTrack = asset.tracks(withMediaType: .audio).first else { return }
                do {
                    try recordAudioTrack.insertTimeRange($0.timeRange, of: audioTrack, at: $0.rangeAtComposition.start)
                } catch {
                    QELog(error)
                }
            }
        }
        
        if composition.tracks(withMediaType: .video).count > 1 {
            setupVideoComposition(from: composition)
        }
        
        if composition.tracks(withMediaType: .audio).count > 1 {
            setupAudioMix()
        }
        
        self.composition = composition
    }
    
}

//MARK: VideoEdit
extension CompositionProject {
    
    public func addVideos(from segments: [CompositionVideoSegment]) {
        self.videoSegments.append(contentsOf: segments)
        refreshComposition()
    }
    
    public func removeVideo(for segment: CompositionVideoSegment) {
        videoSegments.removeAll { (s) -> Bool in
            return s.id == segment.id
        }
        refreshComposition()
    }
    
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
                let newSegment = CompositionVideoSegment(url: url)
                newSegment.timeRange = CMTimeRange(start: time, duration: segment.asset.duration - time)
                segment.removeAfterRangeAt(time: time)
                videoSegments.insert(newSegment, at: i + 1)
                break
            }
        }
        refreshComposition()
    }
    
    public func changeSpeed(at segment: CompositionVideoSegment, scale: Float) {
        guard let composition = composition else { return }
        let scaleDuration = segment.duration * Double(scale)
        let timeRange = segment.rangeAtComposition
        let toDuration = CMTime(seconds: scaleDuration, preferredTimescale: 600)
        composition.scaleTimeRange(timeRange, toDuration: toDuration)
        //直接拉伸图片数据源轨道
        imageSourceComposition!.scaleTimeRange(timeRange, toDuration: toDuration)
        //再把数据源的range也拉伸
        segment.rangeAtComposition.duration = toDuration
        //重新生成videoComposition
        videoComposition = AVMutableVideoComposition(propertiesOf: composition)
    }
    
    //MARK: Reverse
    public func reverseVideo(at segment: CompositionVideoSegment, closure: @escaping (_ error: Error?) -> Void) {
        guard let composition = composition else { return }
        do {
            reverseTool = try ReverseVideoTool(with: composition.mutableCopy() as! AVMutableComposition, at: segment.rangeAtComposition)
        } catch {
            closure(error)
            return
        }
        reverseTool!.completionClosure = { [unowned self] (asset, error) in
            if let asset = asset {
                self.replaceVideoSegment(segment, with: asset)
                closure(nil)
            } else if let error = error {
                closure(error)
            }
            self.reverseTool = nil
        }
        reverseTool!.reverse()
    }
    
    //MARK: Transition
    public func addTransition(_ transition: CompositionTransitionModel, at index: Int) {
        guard 0 <= index && index < videoSegments.count else {
            QELog("转场特效添加错误!")
            return
        }
        videoSegments[index].transition = transition
        refreshComposition()
    }
    
}

//MARK: Music
extension CompositionProject {
    
    public func addMusic(_ asset: AVAsset, at time: CMTime) -> CompositionAudioSegment? {
        guard let composition = composition else { return nil }
        let segment = CompositionAudioSegment(asset: asset)
        var nextSegment: CompositionAudioSegment?
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
            //如果没有则根据长度插入
            let duration: CMTime
            if segment.asset.duration < composition.duration - time {
                duration = segment.asset.duration
            } else {
                duration = composition.duration - time
            }
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
    public func updateMusic(_ segment: CompositionAudioSegment, timeRange: CMTimeRange) {
        guard musicSegments.count > 0 else { return }
        let tuple = findPreAndNextSegments(from: segment, in: musicSegments)
        let preSegment = tuple.pre
        let nextSegment = tuple.next
        let index = tuple.index
        updateAudio(preSegment: preSegment, nextSegment: nextSegment, segment: segment, timeRange: timeRange)
        musicSegments[index] = segment
        refreshComposition()
    }
    
    public func replaceMusic(oldSegment: CompositionAudioSegment, for newSegment: CompositionAudioSegment) {
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
    
    public func removeMusic(_ segment: CompositionAudioSegment) {
        removeAudio(segment, in: &musicSegments)
        refreshComposition()
    }
    
    public func updateMusic(_ segment: CompositionAudioSegment, volume: Float) {
        updateAudio(segment, in: musicSegments, volume: volume)
    }
    
    public func updateMusic(_ segment: CompositionAudioSegment, isFadeIn: Bool) {
        updateAudio(segment, in: musicSegments, isFadeIn: isFadeIn)
    }
    
    public func updateMusic(_ segment: CompositionAudioSegment, isFadeOut: Bool) {
        updateAudio(segment, in: musicSegments, isFadeOut: isFadeOut)
    }
    
    public func updateMusic(_ segment: CompositionAudioSegment, atNew start: CMTime) {
        updateAudio(segment, in: musicSegments, atNew: start)
    }
    
}

//MARK: RecordAudio
extension CompositionProject {
    
    public func addRecordAudio(_ asset: AVAsset, at time: CMTime) -> CompositionAudioSegment? {
        guard let composition = composition else { return nil }
        let segment = CompositionAudioSegment(asset: asset)
        var nextSegment: CompositionAudioSegment?
        var index = 0
        var offset = composition.duration.seconds
        for i in 0..<recordAudioSegments.count {
            let s = recordAudioSegments[i]
            //校验添加的segment是否在别的segment段中
            if segment.rangeAtComposition.start.between(s.rangeAtComposition) {
                QELog("此位置不能插入录音")
                return nil
            }
            //找到下一个segment
            if i + 1 < recordAudioSegments.count {
                let ns = recordAudioSegments[i + 1]
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
            //如果没有则根据长度插入
            let duration: CMTime
            if segment.asset.duration < composition.duration - time {
                duration = segment.asset.duration
            } else {
                duration = composition.duration - time
            }
            segment.timeRange = CMTimeRange(start: .zero, duration: duration)
            segment.rangeAtComposition = CMTimeRange(start: time, duration: duration)
        }
        recordAudioSegments.insert(segment, at: index)
        //从新生成composition
        refreshComposition()
        return segment
    }
    
    public func updateRecord(_ segment: CompositionAudioSegment, timeRange: CMTimeRange) {
        guard recordAudioSegments.count > 0 else { return }
        let tuple = findPreAndNextSegments(from: segment, in: recordAudioSegments)
        let preSegment = tuple.pre
        let nextSegment = tuple.next
        let index = tuple.index
        updateAudio(preSegment: preSegment, nextSegment: nextSegment, segment: segment, timeRange: timeRange)
        recordAudioSegments[index] = segment
        refreshComposition()
    }
    
    public func removeRecord(_ segment: CompositionAudioSegment) {
        removeAudio(segment, in: &recordAudioSegments)
        refreshComposition()
    }
    
    public func updateRecord(_ segment: CompositionAudioSegment, volume: Float) {
        updateAudio(segment, in: recordAudioSegments, volume: volume)
    }
    
    public func updateRecord(_ segment: CompositionAudioSegment, isFadeIn: Bool) {
        updateAudio(segment, in: recordAudioSegments, isFadeIn: isFadeIn)
    }
    
    public func updateRecord(_ segment: CompositionAudioSegment, isFadeOut: Bool) {
        updateAudio(segment, in: recordAudioSegments, isFadeOut: isFadeOut)
    }
    
    public func updateRecord(_ segment: CompositionAudioSegment, atNew start: CMTime) {
        updateAudio(segment, in: recordAudioSegments, atNew: start)
    }
    
}

//MARK: Caption

extension CompositionProject {
    
    @discardableResult
    public func addCaption(_ text: String, at range: CMTimeRange) -> CompositionCaptionSegment? {
        //1.检查数据有效性并找到合适的插入位置
        guard let composition = composition else { return nil }
        guard range.end <= composition.duration else {
            return nil
        }
        var i = 0
        for segment in captionSegments {
            if segment.rangeAtComposition.overlapWith(range) {
                return nil
            }
            if segment.rangeAtComposition.end <= range.start {
                i += 1
            }
        }
        //2.插入字幕
        let segment = CompositionCaptionSegment(text: text, at: range)
        captionSegments.insert(segment, at: i)
        generateSyncLayer()
        return segment
    }
    
    public func removeCaption(segment: CompositionCaptionSegment) {
        captionSegments.removeAll { (s) -> Bool in
            return s == segment
        }
        generateSyncLayer()
    }
    
    @discardableResult
    public func updateCaption(segment: CompositionCaptionSegment) -> Bool {
        guard captionSegments.count > 0 else {
            return false
        }
        var i = 0
        for s in captionSegments {
            if s == segment {
                break
            }
            i += 1
        }
        if i < captionSegments.count {
            captionSegments[i] = segment
            generateSyncLayer()
            return true
        }
        //大于的话就是没找到
        return false
    }
    
}

//MARK: Private
extension CompositionProject {
    
    private func setupSingleVideoTrackComposition(_ composition: AVMutableComposition) {
        let segment = videoSegments.first!
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let imageSourceTrack = imageSourceComposition!.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        let asset = segment.asset
        videoSegments.first!.trackId = videoTrack.trackID
        
        do {
            try videoTrack.insertTimeRange(segment.timeRange, of: asset.tracks(withMediaType: .video).first!, at: .zero)
            if let sourceAudioTrack = asset.tracks(withMediaType: .audio).first {
                try audioTrack.insertTimeRange(segment.timeRange, of: sourceAudioTrack, at: .zero)
            }
            try imageSourceTrack.insertTimeRange(segment.timeRange, of: asset.tracks(withMediaType: .video).first!, at: .zero)
        } catch {
            QELog(error)
        }
        
        segment.rangeAtComposition = CMTimeRange(start: .zero, duration: segment.timeRange.duration)
    }
    
    private func setupMixVideoTrackComposition(_ composition: AVMutableComposition) {
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
        
    }
    
    private func setupTransition(_ transitions: [CompositionTransitionModel]) {
        guard let videoComposition = videoComposition else {
            return
        }
        let instructions = CompositionTransitionInstructionBulder.buildInstructions(videoComposition: videoComposition, transitions: transitions)
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
        guard let composition = composition else { return }
        let mixAudioTrack = composition.tracks(withMediaType: .audio)[1]
        let recordTrack = composition.tracks(withMediaType: .audio)[2]
        //设置混音
        //todo:原声的设置
        let mixParam = AVMutableAudioMixInputParameters(track: mixAudioTrack)
        setupInputParameters(mixParam, for: musicSegments)
        let recordParam = AVMutableAudioMixInputParameters(track: recordTrack)
        setupInputParameters(recordParam, for: recordAudioSegments)
        audioMix!.inputParameters = [mixParam, recordParam]
    }
    
    private func setupVideoComposition(from composition: AVMutableComposition) {
        videoComposition = AVMutableVideoComposition(propertiesOf: composition)
        setupTransition(videoSegments.map({ (segment) -> CompositionTransitionModel in
            return segment.transition
        }))
    }
    
    private func setupInputParameters(_ param: AVMutableAudioMixInputParameters, for segments: [CompositionAudioSegment]) {
        for segment in segments {
            var start = segment.rangeAtComposition.start
            if segment.isFadeIn {
                let duration = min(segment.styleDuration, segment.rangeAtComposition.duration.seconds)
                let newEnd = segment.rangeAtComposition.start + CMTime(seconds: duration, preferredTimescale: 600)
                let range = CMTimeRange(start: segment.rangeAtComposition.start, end: newEnd)
                param.setVolumeRamp(fromStartVolume: 0, toEndVolume: segment.volume, timeRange: range)
                start = newEnd
            }
            param.setVolume(segment.volume, at: start)
            if segment.isFadeOut {
                let duration = min(segment.styleDuration, segment.rangeAtComposition.duration.seconds)
                let newStart = segment.rangeAtComposition.end - CMTime(seconds: duration, preferredTimescale: 600)
                let range = CMTimeRange(start: newStart, end: segment.rangeAtComposition.end)
                param.setVolumeRamp(fromStartVolume: segment.volume, toEndVolume: 0, timeRange: range)
            }
        }
    }
    
    private func replaceVideoSegment(_ segment: CompositionVideoSegment, with asset: AVAsset) {
        let newSegment = CompositionVideoSegment(asset: asset)
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
    
    private func findPreAndNextSegments(from segment: CompositionAudioSegment, in segments: [CompositionAudioSegment]) -> (pre: CompositionAudioSegment?, next: CompositionAudioSegment?, index: Int) {
        var preSegment: CompositionAudioSegment?
        var nextSegment: CompositionAudioSegment?
        var index = 0
        for i in 0..<segments.count {
            let currentSegment = segments[i]
            if currentSegment.id == segment.id {
                if i > 0 {
                    preSegment = segments[i - 1]
                }
                if i + 1 < musicSegments.count {
                    nextSegment = segments[i + 1]
                }
                index = i
                break
            }
        }
        return (pre: preSegment, next: nextSegment, index: index)
    }
    
    private func updateAudio(preSegment: CompositionAudioSegment?, nextSegment: CompositionAudioSegment?, segment: CompositionAudioSegment, timeRange: CMTimeRange) {
        guard let composition = composition else { return }
        var timeRange = timeRange
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
    }
    
    private func removeAudio(_ segment: CompositionAudioSegment, in segments: inout [CompositionAudioSegment]) {
        segments.removeAll {
            return $0 == segment
        }
    }
    
    private func updateAudio(_ segment: CompositionAudioSegment, in segments: [CompositionAudioSegment], volume: Float) {
        for s in segments {
            if s == segment {
                s.volume = volume
                break
            }
        }
        refreshComposition()
    }

    private func updateAudio(_ segment: CompositionAudioSegment, in segments: [CompositionAudioSegment], isFadeIn: Bool) {
        for s in segments {
            if s == segment {
                s.isFadeIn = isFadeIn
                break
            }
        }
        refreshComposition()
    }

    private func updateAudio(_ segment: CompositionAudioSegment, in segments: [CompositionAudioSegment], isFadeOut: Bool) {
        for s in segments {
            if s == segment {
                s.isFadeOut = isFadeOut
                break
            }
        }
        refreshComposition()
    }

    private func updateAudio(_ segment: CompositionAudioSegment, in segments: [CompositionAudioSegment], atNew start: CMTime) {
        for s in segments {
            if s == segment {
                if start + s.rangeAtComposition.duration <= s.asset.duration {
                    s.timeRange = CMTimeRange(start: start, duration: s.rangeAtComposition.duration)
                } else {
                    s.timeRange = CMTimeRange(start: start, end: s.asset.duration)
                    s.rangeAtComposition = CMTimeRange(start: s.rangeAtComposition.start, duration: s.timeRange.duration)
                    segment.rangeAtComposition = s.rangeAtComposition
                }
                segment.timeRange = s.timeRange
                break
            }
        }
        refreshComposition()
    }
    
    /// Build player sync animation layer
    private func generateSyncLayer() {
        guard captionSegments.count > 0 else { return }
        let layer = CALayer()
        layer.frame = player.playerView.bounds
        captionSegments.forEach {
            layer.addSublayer($0.buildLayer(for: layer.bounds))
        }
        player.animationLayer = layer
    }
    
}
