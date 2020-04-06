//
//  CompositionProjectConfig.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/6.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation

extension CompositionProject {
    
    public func exportProject() -> [String: Any] {
        var info: [String: Any] = [:]
        info["video"] = videoSegments.map({ (s) -> [String: Any] in
            return s.toJSON()
        })
        info["music"] = musicSegments.map({ (s) -> [String: Any] in
            return s.toJSON()
        })
        info["record_audio"] = recordAudioSegments.map({ (s) -> [String: Any] in
            return s.toJSON()
        })
        info["caption"] = captionSegments.map({ (s) -> [String: Any] in
            return s.toJSON()
        })
        info["filter"] = selectedFilter.name()
        info["brightness"] = brightness
        info["exposure"] = exposure
        info["contrast"] = contrast
        info["saturation"] = saturation
        return info
    }
    
    public func importProject(info: [String: Any]) throws {
        videoSegments = try ((info["video"] as? [[String: Any]]) ?? []).map({ (json) -> CompositionVideoSegment in
            return try CompositionVideoSegment(json: json)
        })
        musicSegments = try ((info["music"] as? [[String: Any]]) ?? []).map({ (json) -> CompositionAudioSegment in
            return try CompositionAudioSegment(json: json)
        })
        recordAudioSegments = try ((info["record_audio"] as? [[String: Any]]) ?? []).map({ (json) -> CompositionAudioSegment in
            return try CompositionAudioSegment(json: json)
        })
        captionSegments = try ((info["caption"] as? [[String: Any]]) ?? []).map({ (json) -> CompositionCaptionSegment in
            return try CompositionCaptionSegment(json: json)
        })
        if let filter = info["filter"] as? String {
            selectedFilter = CompositionFilter.filter(name: filter)
        }
        brightness = (info["brightness"] as? Float) ?? 0
        exposure = (info["exposure"] as? Float) ?? 0
        contrast = (info["contrast"] as? Float) ?? 1.0
        saturation = (info["saturation"] as? Float) ?? 1.0
        
        refreshComposition()
    }
    
}
