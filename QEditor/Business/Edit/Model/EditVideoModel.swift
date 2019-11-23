//
//  EditVideoModel.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/10.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

/// 剪辑切片后部分的model
struct EditVideoPartModel {
    let beginTime: Double
    let endTime: Double
}

/// 描述剪辑整个视频轨道的model
struct EditVideoModel {
    var composition: AVMutableComposition
    var formatTime: String
    let url: URL
}
