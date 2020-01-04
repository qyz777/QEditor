//
//  CMTime+Edit.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/4.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

extension CMTime {
    
    func between(_ range: CMTimeRange) -> Bool {
        return range.start.seconds <= seconds && seconds <= range.end.seconds
    }
    
}
