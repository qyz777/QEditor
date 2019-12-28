//
//  EditGaussianBlurFilterOperation.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/22.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//
//  高斯模糊

import Foundation
import AVFoundation

class EditGaussianBlurFilterOperation: EditFilterOperation {
    
    var nextOperation: EditFilterOperation?
    
    func excute(_ source: CIImage, at time: CMTime, with context: [String: (value: Float, range: CMTimeRange)]) -> CIImage {
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(source, forKey: kCIInputImageKey)
        var hasOutput = false
        if let v = context[EditFilterGaussianBlurKey] {
            if time.between(v.range) {
                filter?.setValue(v.value, forKey: "inputRadius")
                hasOutput = true
            }
        }
        let output = hasOutput ? filter!.outputImage!.cropped(to: source.extent) : source
        return nextOperation?.excute(output, at: time, with: context) ?? output
    }
    
}
