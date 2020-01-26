//
//  EditCompositionSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/21.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

protocol EditCompositionSegment {
    
    /// 所在轨道的Id
    var trackId: CMPersistentTrackID { get set }
    
    /// segment的唯一标识符
    var id: Int { get }
    
    /// segment的媒体数据源
    var asset: AVAsset { get }
    
    /// segment的数据源url
    var url: URL? { get }
    
    /// segment的时长
    var duration: Double { get }
    
    /// segment在composition中的range
    var rangeAtComposition: CMTimeRange { get }
    
    /// 用来插入到composition的range
    var timeRange: CMTimeRange { get }
    
    init(url: URL)
    
    init(asset: AVAsset)
    
}
