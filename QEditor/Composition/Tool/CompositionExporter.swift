//
//  CompositionExporter.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/5.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation
import GPUImage

public class CompositionExporter {
    
    public var progressClosure: ((_ progress: Float) -> Void)?
    
    public var completion: ((_ url: URL) -> Void)?
    
    let asset: AVAsset
    let videoComposition: AVVideoComposition?
    let audioMix: AVAudioMix?
    let filters: [ImageProcessingOperation]
    let animationTool: AVVideoCompositionCoreAnimationTool?
    let exportURL: URL
    
    var input: MovieInput?
    var output: MovieOutput?
    
    let tmpExportURL: URL?
    
    public init(asset: AVAsset, videoComposition: AVVideoComposition? = nil, audioMix: AVAudioMix? = nil, filters: [ImageProcessingOperation], animationTool: AVVideoCompositionCoreAnimationTool? = nil,  exportURL: URL) {
        self.asset = asset
        self.videoComposition = videoComposition
        self.audioMix = audioMix
        self.filters = filters
        self.animationTool = animationTool
        self.exportURL = exportURL
        if self.animationTool != nil {
            tmpExportURL = URL(fileURLWithPath: String.qe.tmpPath() + String.qe.timestamp() + "_tmp.mp4")
        } else {
            tmpExportURL = nil
        }
    }
    
    public func prepare() -> Bool {
        guard !FileManager.default.fileExists(atPath: exportURL.absoluteString) else {
            return false
        }
        guard let videoTrack = asset.tracks(withMediaType:AVMediaType.video).first else { return false }
        let audioTrack = asset.tracks(withMediaType:AVMediaType.audio).first
        
        let audioDecodingSettings = [AVFormatIDKey: kAudioFormatLinearPCM]
        var acl = AudioChannelLayout()
        memset(&acl, 0, MemoryLayout<AudioChannelLayout>.size)
        acl.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo
        let audioEncodingSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: AVAudioSession.sharedInstance().sampleRate,
            AVChannelLayoutKey: NSData(bytes:&acl, length:MemoryLayout<AudioChannelLayout>.size),
            AVEncoderBitRateKey: 96000
        ]
        
        do {
            try input = MovieInput(asset: asset, videoComposition: videoComposition, audioMix: audioMix, audioSettings: audioDecodingSettings)
        } catch {
            return false
        }
        
        let videoEncodingSettings: [String: Any] = [
            AVVideoCompressionPropertiesKey: [
                AVVideoExpectedSourceFrameRateKey: videoTrack.nominalFrameRate,
                AVVideoAverageBitRateKey: videoTrack.estimatedDataRate,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel,
                AVVideoH264EntropyModeKey: AVVideoH264EntropyModeCABAC,
                AVVideoAllowFrameReorderingKey: videoTrack.requiresFrameReordering],
            AVVideoCodecKey: AVVideoCodecType.h264]
        
        do {
            try output = MovieOutput(URL: tmpExportURL ?? exportURL, size: Size(width: Float(videoTrack.naturalSize.width), height: Float(videoTrack.naturalSize.height)), fileType:.mp4, liveVideo: false, videoSettings: videoEncodingSettings, videoNaturalTimeScale: videoTrack.naturalTimeScale, audioSettings: audioEncodingSettings, audioSourceFormatHint: nil)
        } catch {
            return false
        }
        
        if audioTrack != nil {
            input?.audioEncodingTarget = output
        }
        input?.synchronizedMovieOutput = output
        
        var currentTarget: ImageSource = input!
        filters.forEach {
            currentTarget.addTarget($0, atTargetIndex: 0)
            currentTarget = $0
        }
        currentTarget.addTarget(output!, atTargetIndex: 0)
        
        return true
    }
    
    public func start() {
        input?.completion = { [unowned self] in
            self.output?.finishRecording { [unowned self] in
                DispatchQueue.main.async {
                    if let url = self.tmpExportURL {
                        self.handleCaption(for: AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: NSNumber(value: true)]))
                    } else {
                        self.progressClosure?(1)
                        self.completion?(self.exportURL)
                    }
                }
            }
        }

        input?.progress = { [unowned self] (value) in
            DispatchQueue.main.async {
                self.progressClosure?(Float(value))
            }
        }

        output?.startRecording{ [unowned self] (started, error) in
            guard started else {
                QELog("MovieOutput unable to start writing with error: \(String(describing: error))")
                return
            }
            self.input?.start()
        }
    }
    
    private func handleCaption(for asset: AVAsset) {
        guard let animationTool = animationTool else { return }
        guard let assetVideoTrack = asset.tracks(withMediaType: .video).first else { return }
        guard let assetAudioTrack = asset.tracks(withMediaType: .audio).first else { return }
        let mixComposition = AVMutableComposition()
        guard let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        guard let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else { return }
        do {
            try videoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: assetVideoTrack, at: .zero)
            try audioTrack.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: assetAudioTrack, at: .zero)
        } catch {
            QELog(error)
        }
        
        videoTrack.preferredTransform = assetVideoTrack.preferredTransform
        
        let size = videoTrack.naturalSize
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = size
        videoComposition.animationTool = animationTool
        videoComposition.frameDuration = CMTime(value: 1, timescale: 60)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = exportURL
        exporter?.outputFileType = .mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = videoComposition
        exporter?.exportAsynchronously { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.progressClosure?(1)
                strongSelf.completion?(strongSelf.exportURL)
            }
        }
    }
    
}
