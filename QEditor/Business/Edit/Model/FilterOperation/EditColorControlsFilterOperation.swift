//
//  EditColorControlsFilterOperation.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

class EditColorControlsFilterOperation: EditFilterOperation {
    
    var nextOperation: EditFilterOperation?
    
    func excute(_ filter: CIFilter?, _ context: [String: Any]) -> CIFilter {
        var newFilter = filter
        if newFilter == nil {
            newFilter = CIFilter(name: "CIColorControls")
            newFilter?.setValue(context[EditFilterImageKey], forKey: kCIInputImageKey)
        } else {
            let tempFilter = CIFilter(name: "CIColorControls")
            tempFilter?.setValue(newFilter!.outputImage, forKey: kCIInputImageKey)
            newFilter = tempFilter
        }
        if let value = context[EditFilterBrightnessKey] {
            newFilter?.setValue(value, forKey: "inputBrightness")
        }
        if let value = context[EditFilterSaturationKey] {
            newFilter?.setValue(value, forKey: "inputSaturation")
        }
        //滤镜是nil是个严重的问题!!!
        assert(newFilter != nil)
        return nextOperation?.excute(newFilter, context) ?? newFilter!
    }
    
}
