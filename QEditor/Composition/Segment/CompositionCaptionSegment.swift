//
//  CompositionCaptionSegment.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/7.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

public class CompositionCaptionSegment: CompositionSegment, CompositionSegmentCodable {
    
    public let id: Int
    
    public var duration: Double
    
    public var rangeAtComposition: CMTimeRange {
        willSet {
            duration = newValue.duration.seconds
        }
    }
    
    public var text: String = ""
    
    public var fontSize: CompositionCaptionFontSize = .normal
    
    public var fontName: String = CompositionCaptionFontName.PingFangSC.regular.rawValue
    
    public var textColor: UIColor = UIColor.qe.hex(0xEEEEEE)
    
    public init(text: String, at range: CMTimeRange) {
        id = Int(Date(timeIntervalSince1970: 0).timeIntervalSinceNow)
        self.text = text
        self.rangeAtComposition = range
        duration = rangeAtComposition.duration.seconds
    }
    
    public func toJSON() -> [String : Any] {
        var info: [String: Any] = [:]
        info["text"] = text
        info["start"] = rangeAtComposition.start.seconds
        info["end"] = rangeAtComposition.end.seconds
        info["font_name"] = fontName
        if let data = try? JSONEncoder().encode(fontSize), let jsonString = String(data: data, encoding: .utf8) {
            info["font_size"] = jsonString
        }
        info["text_color"] = textColor.hexString
        return info
    }
    
    public required convenience init(json: [String : Any]) throws {
        guard let text = json["text"] as? String else {
            throw SegmentCodableError.canNotFindText
        }
        guard let start = json["start"] as? Double else {
            throw SegmentCodableError.canNotFindRange
        }
        guard let end = json["end"] as? Double else {
            throw SegmentCodableError.canNotFindRange
        }
        self.init(text: text, at: CMTimeRange(start: start, end: end))
        fontName = (json["font_name"] as? String) ?? CompositionCaptionFontName.PingFangSC.regular.rawValue
        if let fontSizeString = json["font_size"] as? String, let data = fontSizeString.data(using: .utf8) {
            fontSize = try JSONDecoder().decode(CompositionCaptionFontSize.self, from: data)
        }
        if let hexString = json["text_color"] as? String {
            textColor = UIColor(hexString: hexString) ?? UIColor.qe.hex(0xEEEEEE)
        }
    }
    
    /// 构建字幕layer
    /// 注意：视频播放的尺寸与视频实际尺寸不同
    /// 导出视频时需要根据视频实际尺寸重新build一个新layer使用
    /// - Parameter bounds: layer尺寸
    /// - Parameter isExport: 是否是导出模式
    public func buildLayer(for bounds: CGRect, isExport: Bool = false) -> CALayer {
        let layer = CALayer()
        layer.frame = bounds
        layer.opacity = 0
        layer.addSublayer(buildTextLayer(for: bounds, isExport: isExport))
        layer.add(buildFadeInFadeOutAnimation(), forKey: nil)
        return layer
    }
    
    private func buildTextLayer(for bounds: CGRect, isExport: Bool) -> CATextLayer {
        let attributes = [NSAttributedString.Key.font: UIFont(name: fontName, size: isExport ? fontSize.exportSize() : fontSize.size())!, NSAttributedString.Key.foregroundColor: textColor]
        let attrString = NSAttributedString(string: text, attributes: attributes)
        let textSize = text.size(withAttributes: attributes)
        let layer = CATextLayer()
        layer.contentsScale = UIScreen.main.scale
        layer.string = attrString
        layer.bounds = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
        layer.position = CGPoint(x: bounds.midX, y: bounds.maxY - 10 - textSize.height / 2)
        layer.backgroundColor = UIColor.clear.cgColor
        return layer
    }
    
    private func buildFadeInFadeOutAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.values = [NSNumber(value: 0), NSNumber(value: 1.0), NSNumber(value: 1.0), NSNumber(value: 0)]
        animation.keyTimes = [NSNumber(value: 0), NSNumber(value: 0.1), NSNumber(value: 0.9), NSNumber(value: 1)]
        animation.beginTime = AVCoreAnimationBeginTimeAtZero + rangeAtComposition.start.seconds
        animation.duration = rangeAtComposition.duration.seconds
        animation.isRemovedOnCompletion = false
        return animation
    }
    
}

public enum CompositionCaptionFontSize: String, Codable {
    case small
    case normal
    case large
    case superLarge
    
    public func size() -> CGFloat {
        switch self {
        case .small:
            return 13
        case .normal:
            return 15
        case .large:
            return 17
        case .superLarge:
            return 19
        }
    }
    
    public func exportSize() -> CGFloat {
        return size() * 2
    }
}

/// 字体有很多可以往这里补充加
public enum CompositionCaptionFontName {
    public enum PingFangSC: String {
        case regular = "PingFangSC-Regular"
        case medium = "PingFangSC-Medium"
        case semibold = "PingFangSC-Semibold"
        case light = "PingFangSC-Light"
    }
}
