//
//  CompositionFiltersDefine.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/28.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import GPUImage


public enum CompositionFilter: Equatable {
    case none
    case softElegance
    case monochrome
    case blanchedAlmond
    case brightness(value: Float)
    case exposure(value: Float)
    case contrast(value: Float)
    case saturation(value: Float)
    
    func instance() -> ImageProcessingOperation? {
        switch self {
        case .none:
            return nil
        case .softElegance:
            //Must add lookup_soft_elegance_1.png and lookup_soft_elegance_2.png
            //to asset from GPUImage's pod before use!
            return SoftElegance()
        case .monochrome:
            return MonochromeFilter()
        case .blanchedAlmond:
            let mc = MonochromeFilter()
            mc.color = GPUIMAGE_COLOR(red: 255, green: 235, blue: 205, alpha: 0.2)
            return mc
        case .brightness(let value):
            let f = BrightnessAdjustment()
            f.brightness = value
            return f
        case .exposure(value: let value):
            let f = ExposureAdjustment()
            f.exposure = value
            return f
        case .contrast(value: let value):
            let f = ContrastAdjustment()
            f.contrast = value
            return f
        case .saturation(value: let value):
            let f = SaturationAdjustment()
            f.saturation = value
            return f
        }
    }
    
    public func name() -> String {
        switch self {
        case .none:
            return "none"
        case .softElegance:
            return "softElegance"
        case .monochrome:
            return "monochrome"
        case .blanchedAlmond:
            return "blanchedAlmond"
        case .brightness(value: _):
            return "brightness"
        case .exposure(value: _):
            return "exposure"
        case .contrast(value: _):
            return "contrast"
        case .saturation(value: _):
            return "saturation"
        }
    }
    
    public static func filter(name: String) -> CompositionFilter {
        switch name {
        case "none":
            return .none
        case "softElegance":
            return .softElegance
        case "monochrome":
            return .monochrome
        case "blanchedAlmond":
            return .blanchedAlmond
        default:
            return .none
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.name() == rhs.name()
    }
    
}

func GPUIMAGE_COLOR(red: Float, green: Float, blue: Float, alpha: Float) -> Color {
    return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}

func _getMemoryFrom(object: AnyObject) -> String {
    let str = Unmanaged<AnyObject>.passUnretained(object).toOpaque()
    return String(describing: str)
}
