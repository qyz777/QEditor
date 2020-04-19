//
//  CompositionProjectConfig.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/6.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation

extension CompositionProject {
    
    public func exportProject() -> CompositionProjectConfig {
        let config = CompositionProjectConfig()
        config.videoSegments = videoSegments
        config.musicSegments = musicSegments
        config.recordAudioSegments = recordAudioSegments
        config.captionSegments = captionSegments
        config.selectedFilter = selectedFilter
        config.originVolumn = originVolumn
        config.brightness = brightness
        config.exposure = exposure
        config.contrast = contrast
        config.saturation = saturation
        config.id = id
        return config
    }
    
    public func importProject(config: CompositionProjectConfig) {
        videoSegments = config.videoSegments
        musicSegments = config.musicSegments
        recordAudioSegments = config.recordAudioSegments
        captionSegments = config.captionSegments
        selectedFilter = config.selectedFilter
        originVolumn = config.originVolumn
        brightness = config.brightness
        exposure = config.exposure
        contrast = config.contrast
        saturation = config.saturation
        id = config.id
    }
    
}

public class CompositionProjectConfig {
    
    public var videoSegments: [CompositionVideoSegment] = []
    
    public var musicSegments: [CompositionAudioSegment] = []
    
    public var recordAudioSegments: [CompositionAudioSegment] = []
    
    public var captionSegments: [CompositionCaptionSegment] = []
    
    public var selectedFilter: CompositionFilter = .none
    
    public var brightness: Float = 0
    
    public var exposure: Float = 0
    
    public var contrast: Float = 1.0
    
    public var saturation: Float = 1.0
    
    public var originVolumn: Float = 1.0
    
    public var updateTime: String = ""
    
    public var id: String = ""
    
    public init(json: [String: Any]) throws {
        videoSegments = try ((json["video"] as? [[String: Any]]) ?? []).map({ (json) -> CompositionVideoSegment in
            return try CompositionVideoSegment(json: json)
        })
        musicSegments = try ((json["music"] as? [[String: Any]]) ?? []).map({ (json) -> CompositionAudioSegment in
            return try CompositionAudioSegment(json: json)
        })
        recordAudioSegments = try ((json["record_audio"] as? [[String: Any]]) ?? []).map({ (json) -> CompositionAudioSegment in
            return try CompositionAudioSegment(json: json)
        })
        captionSegments = try ((json["caption"] as? [[String: Any]]) ?? []).map({ (json) -> CompositionCaptionSegment in
            return try CompositionCaptionSegment(json: json)
        })
        if let filter = json["filter"] as? String {
            selectedFilter = CompositionFilter.filter(name: filter)
        }
        originVolumn = (json["origin_volumn"] as? Float) ?? 1.0
        brightness = (json["brightness"] as? Float) ?? 0
        exposure = (json["exposure"] as? Float) ?? 0
        contrast = (json["contrast"] as? Float) ?? 1.0
        saturation = (json["saturation"] as? Float) ?? 1.0
        updateTime = (json["time"] as? String) ?? ""
        id = (json["id"] as? String) ?? ""
    }
    
    public init() {}
    
    public func toJSON() -> [String: Any] {
        var json: [String: Any] = [:]
        json["video"] = videoSegments.map({ (s) -> [String: Any] in
            return s.toJSON()
        })
        json["music"] = musicSegments.map({ (s) -> [String: Any] in
            return s.toJSON()
        })
        json["record_audio"] = recordAudioSegments.map({ (s) -> [String: Any] in
            return s.toJSON()
        })
        json["caption"] = captionSegments.map({ (s) -> [String: Any] in
            return s.toJSON()
        })
        json["filter"] = selectedFilter.name()
        json["brightness"] = brightness
        json["exposure"] = exposure
        json["contrast"] = contrast
        json["saturation"] = saturation
        json["origin_volumn"] = originVolumn
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd"
        updateTime = formatter.string(from: date)
        json["time"] = updateTime
        json["id"] = id
        return json
    }
    
}
