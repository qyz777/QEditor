//
//  CompositionExtension.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/28.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

extension CMTimeRange {
    
    init(start: Double, end: Double) {
        self.init(start: CMTime(seconds: start, preferredTimescale: 600), end: CMTime(seconds: end, preferredTimescale: 600))
    }
    
    func overlapWith(_ range: CMTimeRange) -> Bool {
        return (self.start < range.start && range.start < self.end) || (self.start < range.end && range.end < self.end) || (range.start <= self.start && self.end <= range.end)
    }
    
    var description: String {
        return "\(start.seconds) -> \(end.seconds)"
    }
    
}

extension CMTime {
    
    func between(_ range: CMTimeRange) -> Bool {
        return range.start.seconds <= seconds && seconds <= range.end.seconds
    }
    
    static func + (lhs: CMTime, rhs: CMTime) -> CMTime {
        return CMTimeAdd(lhs, rhs)
    }
    
    static func - (lhs: CMTime, rhs: CMTime) -> CMTime {
        return CMTimeSubtract(lhs, rhs)
    }
    
    static func += (lhs: inout CMTime, rhs: CMTime) {
        lhs = lhs + rhs
    }
    
    static func -= (lhs: inout CMTime, rhs: CMTime) {
        lhs = lhs - rhs
    }
    
}

extension String {
    
    static func timestamp() -> String {
        let timeInterval: TimeInterval = Date().timeIntervalSince1970
        return "\(Int(timeInterval))"
    }
    
}
