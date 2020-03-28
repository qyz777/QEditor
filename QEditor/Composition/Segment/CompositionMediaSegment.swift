//
//  CompositionMediaSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/7.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

public protocol CompositionMediaSegment: CompositionSegment {
    
    /// 所在轨道的Id
    var trackId: CMPersistentTrackID { get set }
    
    /// segment的媒体数据源
    var asset: AVAsset { get }
    
    /// segment的数据源url
    var url: URL? { get }
    
    /// 用来插入到composition的range
    var timeRange: CMTimeRange { get }
    
    var isPrepare: Bool { get }
    
    init(url: URL)
    
    init(asset: AVAsset)
    
    func prepare(_ closure: (() -> Void)?)
    
}
