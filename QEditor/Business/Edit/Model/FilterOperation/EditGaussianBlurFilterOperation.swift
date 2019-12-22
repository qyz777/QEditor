//
//  EditGaussianBlurFilterOperation.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/22.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//
//  高斯模糊

import Foundation

class EditGaussianBlurFilterOperation: EditFilterOperation {
    
    var nextOperation: EditFilterOperation?
    
    func excute(_ filter: CIFilter?, _ context: [String: Any]) -> CIFilter {
        var newFilter = filter
        if newFilter == nil {
            newFilter = CIFilter(name: "CIGaussianBlur")
            newFilter?.setValue(context[EditFilterImageKey], forKey: kCIInputImageKey)
        } else {
            let tempFilter = CIFilter(name: "CIGaussianBlur")
            tempFilter?.setValue(newFilter!.outputImage, forKey: kCIInputImageKey)
            newFilter = tempFilter
        }
        if let value = context[EditFilterGaussianBlurKey] {
            newFilter?.setValue(value, forKey: "inputRadius")
        }
        assert(newFilter != nil)
        return nextOperation?.excute(newFilter, context) ?? newFilter!
    }
    
}
