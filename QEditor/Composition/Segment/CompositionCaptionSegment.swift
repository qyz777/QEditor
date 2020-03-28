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

public class CompositionCaptionSegment: CompositionSegment {
    
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
    
    public var font: UIFont {
        return UIFont(name: fontName, size: fontSize.size()) ?? .systemFont(ofSize: 13)
    }
    
    public var textColor: UIColor = UIColor.qe.hex(0xEEEEEE)
    
    public init(text: String, at range: CMTimeRange) {
        id = Int(Date(timeIntervalSince1970: 0).timeIntervalSinceNow)
        self.text = text
        self.rangeAtComposition = range
        duration = rangeAtComposition.duration.seconds
    }
    
    /// 构建字幕layer
    /// 注意：视频播放的尺寸与视频实际尺寸不同
    /// 导出视频时需要根据视频实际尺寸重新build一个新layer使用
    /// - Parameter bounds: layer尺寸
    public func buildLayer(for bounds: CGRect) -> CALayer {
        let layer = CALayer()
        layer.frame = bounds
        layer.opacity = 0
        layer.addSublayer(buildTextLayer(for: bounds))
        layer.add(buildFadeInFadeOutAnimation(), forKey: nil)
        return layer
    }
    
    private func buildTextLayer(for bounds: CGRect) -> CATextLayer {
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
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
        animation.beginTime = rangeAtComposition.start.seconds
        animation.duration = rangeAtComposition.duration.seconds
        animation.isRemovedOnCompletion = false
        return animation
    }
    
}

public enum CompositionCaptionFontSize {
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
