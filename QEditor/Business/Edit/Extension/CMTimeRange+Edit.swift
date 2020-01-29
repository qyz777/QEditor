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
    
    init(start: Double, end: Double) {
        self.init(start: CMTime(seconds: start, preferredTimescale: 600), end: CMTime(seconds: end, preferredTimescale: 600))
    }
    
    var description: String {
        return "\(start.seconds) -> \(end.seconds)"
    }
    
}
