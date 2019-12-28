//
//  EditFilterOperation.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import CoreImage
import AVFoundation

protocol EditFilterOperation {
    
    var nextOperation: EditFilterOperation? { get set }
    
    func excute(_ source: CIImage, at time: CMTime, with context: [String: (value: Float, range: CMTimeRange)]) -> CIImage
    
}

extension CMTime {
    
    func between(_ range: CMTimeRange) -> Bool {
        return range.start.seconds <= seconds && seconds <= range.end.seconds
    }
    
}
