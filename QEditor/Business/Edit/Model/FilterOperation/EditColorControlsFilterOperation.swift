//
//  EditColorControlsFilterOperation.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

class EditColorControlsFilterOperation: EditFilterOperation {
    
    var nextOperation: EditFilterOperation?
    
    func excute(_ source: CIImage, at time: CMTime, with context: [String: (value: Float, range: CMTimeRange)]) -> CIImage {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(source, forKey: kCIInputImageKey)
        var hasOutput = false
        if let v = context[EditFilterBrightnessKey] {
            if time.between(v.range) {
                filter?.setValue(v.value, forKey: "inputBrightness")
                hasOutput = true
            }
        }
        if let v = context[EditFilterSaturationKey] {
            if time.between(v.range) {
                filter?.setValue(v.value, forKey: "inputSaturation")
                hasOutput = true
            }
        }
        if let v = context[EditFilterContrastKey] {
            if time.between(v.range) {
                filter?.setValue(v.value, forKey: "inputContrast")
                hasOutput = true
            }
        }
        let output = hasOutput ? filter!.outputImage!.cropped(to: source.extent) : source
        return nextOperation?.excute(output, at: time, with: context) ?? output
    }
    
}
