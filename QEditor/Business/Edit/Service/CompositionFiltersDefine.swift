//
//  CompositionFiltersDefine.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/28.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import GPUImage


public enum CompositionFilter {
    case none
    case softElegance
    case monochrome
    case blanchedAlmond
    
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
        }
    }
}

func GPUIMAGE_COLOR(red: Float, green: Float, blue: Float, alpha: Float) -> Color {
    return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}

func _getMemoryFrom(object: AnyObject) -> String {
    let str = Unmanaged<AnyObject>.passUnretained(object).toOpaque()
    return String(describing: str)
}
