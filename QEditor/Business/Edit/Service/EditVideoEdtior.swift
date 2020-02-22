//
//  EditVideoEdtior.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/10.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//
//  剪辑最终输出使用的工具
//  fps -> 帧率 每秒的帧数
//  总帧数 = 总时间 * fps

import Foundation
import AVFoundation

public typealias EditorResult = (_ result: Result<URL, Error>) -> Void
public enum EditorError: Error {
    case output
    case url
    
    public var localizedDescription: String {
        switch self {
        case .output:
            return "导出失败"
        case .url:
            return "URL定义失败"
        }
    }
}

let EDIT_VIDEO_FPS: CMTimeScale = 30

class EditVideoEdtior {
    
    private var mixComposition: AVMutableComposition!
    private var audioTrack: AVMutableCompositionTrack!
    private var videoTrack: AVMutableCompositionTrack!
    private var videoComposition: AVMutableVideoComposition!
    
    private let outputDirectoryUrlString = String.qe.documentPath() + "/videos"
    
    private var inputUrl: URL?
    
    public init() {
        let fileManager = FileManager()
        let point = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        if !fileManager.fileExists(atPath: outputDirectoryUrlString, isDirectory: point) {
            do {
                try fileManager.createDirectory(atPath: outputDirectoryUrlString, withIntermediateDirectories: true, attributes: nil)
            } catch {
                QELog(error)
            }
        }
    }
    
    public func loadModels(url: URL) {
        inputUrl = url
    }
    
    public func exportVideoAsynchronouslyWithResult(_ result: @escaping(EditorResult)) {
        //1.初始化轨道
        initComposition()
        //2.注入音视频至轨道
        combineAV()
        //3.设置输出视频的属性
        adjustVideoSettings()
        let outputURL = URL(string: outputDirectoryUrlString + String.qe.timestamp())
        guard outputURL != nil else {
            result(.failure(EditorError.url))
            return
        }
        //4.输出
        let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = outputURL
        exporter?.videoComposition = videoComposition
        //暂时先写个mov吧
        exporter?.outputFileType = .mov
        //暂时先写个YES
        exporter?.shouldOptimizeForNetworkUse = true
        //todo: 监听进度
        exporter?.exportAsynchronously(completionHandler: { [weak exporter] in
            guard let e = exporter else {
                result(.failure(EditorError.output))
                return
            }
            DispatchQueue.main.sync {
                if e.status == .completed {
                    result(.success(outputURL!))
                } else {
                    result(.failure(e.error ?? EditorError.output))
                }
            }
        })
    }
    
    private func initComposition() {
        mixComposition = AVMutableComposition()
        audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
    }
    
    private func combineAV() {
//        var totalDutation: CMTime = .zero
//        videoModels.forEach { (model) in
//            let asset = AVURLAsset(url: inputUrl!)
//            let range = CMTimeRange(start: CMTime(seconds: model.beginTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), end: CMTime(seconds: model.endTime - model.beginTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
//
//            do {
//                try insertAudio(asset, with: range, at: totalDutation)
//                try insertVideo(asset, with: range, at: totalDutation)
//            } catch {
//                QELog(error)
//            }
//
//            let newDuration = CMTime(seconds: model.endTime - model.beginTime, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//            totalDutation = CMTimeAdd(totalDutation, newDuration)
//        }
    }
    
    private func insertAudio(_ asset: AVAsset, with timeRange: CMTimeRange, at startTime: CMTime) throws {
        guard let assetAudioTrack = asset.tracks(withMediaType: .audio).first else {
            return
        }
        try audioTrack.insertTimeRange(timeRange, of: assetAudioTrack, at: startTime)
    }
    
    private func insertVideo(_ asset: AVAsset, with timeRange: CMTimeRange, at startTime: CMTime) throws {
        guard let assetVideoTrack = asset.tracks(withMediaType: .video).first else {
            return
        }
        try videoTrack.insertTimeRange(timeRange, of: assetVideoTrack, at: startTime)
    }
    
    private func adjustVideoSettings() {
        videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTime(value: 1, timescale: EDIT_VIDEO_FPS)
        
        //todo: 转向、尺寸
        
        //创建视频组合指令
//        let instruction = AVMutableVideoCompositionInstruction()
//        instruction.timeRange = CMTimeRange(start: .zero, end: mixComposition.duration)
//        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        //todo: 转场
    }
    
}

public extension Namespace where Base: AVAsset {
    
    func getFixVideoTransform() -> CGAffineTransform {
        let degress = base.qe.videoDegress()
        let translateToCenter: CGAffineTransform
        let mixedTransform: CGAffineTransform
        let tracks = base.tracks(withMediaType: .video)
        guard tracks.count > 0 else {
            return .identity
        }
        let videoTrack = tracks.first!
        if degress == 90 {
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0)
            mixedTransform = translateToCenter.rotated(by: CGFloat.pi / 2)
        } else if degress == 180 {
            translateToCenter = CGAffineTransform(translationX: videoTrack.naturalSize.width, y: 0)
            mixedTransform = translateToCenter.rotated(by: CGFloat.pi)
        } else if degress == 270 {
            translateToCenter = CGAffineTransform(translationX: 0, y: videoTrack.naturalSize.width)
            mixedTransform = translateToCenter.rotated(by: CGFloat.pi / 2)
        } else {
            mixedTransform = .identity
        }
        return mixedTransform
    }
    
    func videoDegress() -> Int {
        var degress = 0
        let tracks = base.tracks(withMediaType: .video)
        guard tracks.count > 0 else {
            return degress
        }
        let videoTrack = tracks.first!
        let t = videoTrack.preferredTransform
        if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
            // Portrait
            degress = 90
        } else if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0 {
            // PortraitUpsideDown
            degress = 270
        } else if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0 {
            // LandscapeRight
            degress = 0
        } else if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
            // LandscapeLeft
            degress = 180
        }
        return degress
    }
    
    static func radiansToDegrees(_ radians: CGFloat) -> CGFloat {
        return radians * 180 / CGFloat.pi
    }
    
}
