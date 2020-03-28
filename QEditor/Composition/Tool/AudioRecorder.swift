//
//  AudioRecorder.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/31.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

fileprivate let SAVE_PATH = String.qe.documentPath() + "/RecordAudio"

public class AudioRecorder {
    
    public let recorder: AVAudioRecorder
    
    public var finishClosure: ((_ flag: Bool, _ url: URL) -> Void)? {
        return delegateHandler.finishClosure
    }
    
    /// 由于AVAudioRecorderDelegate继承NSObjectProtocol 所以引入这个类处理代理避免污染主类
    private var delegateHandler = EditAudioRecorderDelegateHandler()
    
    public init() throws {
        let point = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        point.initialize(to: ObjCBool(true))
        if !FileManager.default.fileExists(atPath: SAVE_PATH, isDirectory: point) {
            try FileManager.default.createDirectory(atPath: SAVE_PATH, withIntermediateDirectories: true, attributes: nil)
        }
        point.deinitialize(count: 1)
        point.deallocate()
        let timestamp = String.qe.timestamp()
        let fileURL = URL(fileURLWithPath: SAVE_PATH + "/" + timestamp + ".caf")
        //注意设置参数 设置不对就无法录制
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleIMA4,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderBitDepthHintKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        recorder = try AVAudioRecorder(url: fileURL, settings: settings)
        recorder.isMeteringEnabled = true
        recorder.delegate = delegateHandler
        recorder.prepareToRecord()
    }
    
    public func record() {
        if AVAudioSession.sharedInstance().category != .playAndRecord {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: .defaultToSpeaker)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                QELog(error)
            }
        }
        recorder.record()
    }
    
    public func pause() {
        recorder.pause()
    }
    
    public func stop(_ closure: @escaping (_ flag: Bool, _ url: URL) -> Void) {
        delegateHandler.finishClosure = closure
        recorder.stop()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .defaultToSpeaker)
        } catch {
            QELog(error)
        }
    }
    
}

fileprivate class EditAudioRecorderDelegateHandler: NSObject {
    
    var finishClosure: ((_ flag: Bool, _ url: URL) -> Void)?
    
}

extension EditAudioRecorderDelegateHandler: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        finishClosure?(flag, recorder.url)
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        guard let error = error else { return }
        QELog(error)
    }
    
}
