//
//  EditComposition.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/21.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  代码优化需要使用的类

import Foundation
import AVFoundation

class EditComposition {
    
    public var composition: AVMutableComposition?
    
    public var videoComposition: AVMutableVideoComposition?
    
//    暂时先不用
//    var audioMix: AVAudioMix?
    
    /// 获取视频长度字符串
    public var durationString: String {
        guard let composition = composition else {
            return ""
        }
        return String.qe.formatTime(Int(composition.duration.seconds))
    }
    
    public var segments: [EditCompositionVideoSegment] = []
    
}
