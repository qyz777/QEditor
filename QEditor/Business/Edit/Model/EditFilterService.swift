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

/// CIImage，滤镜处理链的数据源
let EditFilterImageKey = "EditFilterImageKey"

enum AdjustError: Error {
    case filterError
}

class EditFilterService {
    
    public var videoComposition: AVMutableVideoComposition?
    
    private let operation: EditFilterOperation
    
    private let imageContext = CIContext(options: nil)
    
    private var context: [String: Any] = [:]
    
    public private(set) var brightness: Float = 0
    
    public private(set) var saturation: Float = 1
    
    init() {
        operation = EditColorControlsFilterOperation()
    }
    
    public func adjust(_ composition: AVMutableComposition, with context: [String: Any]) -> AVPlayerItem {
        context.forEach {
            self.context[$0.key] = $0.value
        }
        updateState()
        videoComposition = AVMutableVideoComposition(asset: composition) { [weak self] (request) in
            guard let strongSelf = self else { return }
            let source = request.sourceImage
            strongSelf.context[EditFilterImageKey] = source
            let filter = strongSelf.operation.excute(nil, strongSelf.context)
            strongSelf.context.removeValue(forKey: EditFilterImageKey)
            if let result = filter.outputImage?.cropped(to: source.extent) {
                request.finish(with: result, context: nil)
            } else {
                request.finish(with: AdjustError.filterError)
            }
        }
        let item = AVPlayerItem(asset: composition)
        item.videoComposition = videoComposition
        return item
    }
    
    private func updateState() {
        if let value = context[EditFilterBrightnessKey] {
            brightness = value as! Float
        }
        if let value = context[EditFilterSaturationKey] {
            saturation = value as! Float
        }
    }
    
}
