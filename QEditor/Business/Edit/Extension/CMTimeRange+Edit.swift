//
//  CMTimeRange+Edit.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/4.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

extension CMTimeRange {
    
    init(beginTime: Double, endTime: Double) {
        self.init(start: CMTime(seconds: beginTime, preferredTimescale: 600), end: CMTime(seconds: endTime, preferredTimescale: 600))
    }
    
}
