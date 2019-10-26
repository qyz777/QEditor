//
//  EditToolService.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//  fps -> 帧率 每秒的帧数
//  总帧数 = 总时间 * fps

import UIKit
import AVFoundation

class EditToolService {

    func split(video model: MediaVideoModel) -> [CMTime] {
        guard model.url != nil else {
            return []
        }

        let asset = AVURLAsset(url: model.url!)
        let duration = Int(asset.duration.seconds)

        var times: [CMTime] = []
        for i in 1...duration {
            let time = CMTime(seconds: Double(i), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            times.append(time)
        }
        return times
    }
    
}
