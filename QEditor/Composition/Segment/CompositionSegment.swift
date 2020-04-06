//
//  CompositionSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/21.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

struct AVAssetKey {
    static let tracks = "tracks"
    static let duration = "duration"
    static let metadata = "commonMetadata"
}

public protocol CompositionSegment {
    
    /// segment的唯一标识符
    var id: Int { get }
    
    /// segment的时长
    var duration: Double { get }
    
    /// segment在composition中的range
    var rangeAtComposition: CMTimeRange { get }
    
}

public protocol CompositionSegmentCodable {
    
    func toJSON() -> [String: Any]
    
    init(json: [String: Any]) throws
    
}

public func == (lhs: CompositionSegment, rhs: CompositionSegment) -> Bool {
    return lhs.id == rhs.id
}

public enum SegmentCodableError: Error {
    case canNotFindURL
    case canNotFindRange
    case canNotFindTransition
    case canNotFindText
}
