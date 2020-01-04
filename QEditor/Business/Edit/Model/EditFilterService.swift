//
//  EditFilterService.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage

/// 亮度 默认为0，取值范围为 -1～1
let EditFilterBrightnessKey = "EditFilterBrightnessKey"

/// 饱和度 默认为1 取值范围为 -30 ～ 30
let EditFilterSaturationKey = "EditFilterSaturationKey"

/// 对比度 默认为1 取值范围为 -30 ～ 30
let EditFilterContrastKey = "EditFilterContrastKey"

/// 高斯模糊 默认为0 取值范围 0 ～ 20
let EditFilterGaussianBlurKey = "EditFilterGaussianBlurKey"

class EditFilterService {
    
    private var operation: EditFilterOperation
    
    private let imageContext = CIContext(options: nil)
    
    private var context: [String: (value: Float, range: CMTimeRange)] = [:]
    
    public private(set) var brightness: Float = 0
    
    public private(set) var saturation: Float = 1
    
    public private(set) var contrast: Float = 1
    
    public private(set) var gaussianBlur: Float = 0
    
    init() {
        let colorControlsOperation = EditColorControlsFilterOperation()
        let gaussianBlurOperation = EditGaussianBlurFilterOperation()
        colorControlsOperation.nextOperation = gaussianBlurOperation
        operation = colorControlsOperation
    }
    
    public func adjust(_ composition: AVMutableComposition, with context: [String: (value: Float, range: CMTimeRange)]) -> AVMutableVideoComposition {
        context.forEach {
            self.context[$0.key] = $0.value
        }
        updateState()
        return AVMutableVideoComposition(asset: composition) { [weak self] (request) in
            guard let strongSelf = self else { return }
            let source = request.sourceImage
            let output = strongSelf.operation.excute(source, at: request.compositionTime, with: strongSelf.context)
            request.finish(with: output, context: nil)
        }
    }
    
    private func updateState() {
        if let v = context[EditFilterBrightnessKey] {
            brightness = v.value
        }
        if let v = context[EditFilterSaturationKey] {
            saturation = v.value
        }
        if let v = context[EditFilterContrastKey] {
            contrast = v.value
        }
        if let v = context[EditFilterGaussianBlurKey] {
            gaussianBlur = v.value
        }
    }
    
}
