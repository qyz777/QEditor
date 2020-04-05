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
    let exportURL: URL
    
    var input: MovieInput?
    var output: MovieOutput?
    
    public init(asset: AVAsset, videoComposition: AVVideoComposition? = nil, audioMix: AVAudioMix? = nil, filters: [ImageProcessingOperation], exportURL: URL) {
        self.asset = asset
        self.videoComposition = videoComposition
        self.audioMix = audioMix
        self.filters = filters
        self.exportURL = exportURL
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
            try output = MovieOutput(URL: exportURL, size: Size(width: Float(videoTrack.naturalSize.width), height: Float(videoTrack.naturalSize.height)), fileType:.mp4, liveVideo: false, videoSettings: videoEncodingSettings, videoNaturalTimeScale: videoTrack.naturalTimeScale, audioSettings: audioEncodingSettings, audioSourceFormatHint: nil)
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
        guard let input = input else { return }
        guard let output = output else { return }
        
        input.completion = {
            output.finishRecording {
                input.audioEncodingTarget = nil
                input.synchronizedMovieOutput = nil
                
                DispatchQueue.main.async {
                    self.completion?(self.exportURL)
                }
            }
        }
        
        input.progress = { [unowned self] (value) in
            DispatchQueue.main.async {
                self.progressClosure?(Float(value))
            }
        }
        
        output.startRecording{ (started, error) in
            guard started else {
                QELog("MovieOutput unable to start writing with error: \(String(describing: error))")
                return
            }
            input.start()
        }
    }
    
}
