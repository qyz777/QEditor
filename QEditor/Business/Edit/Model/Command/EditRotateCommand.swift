//
//  EditRotateCommand.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/4.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

struct EditRotateCommandContext: EditCommandContext {
    let range: CMTimeRange
    let degress: CGFloat
}

class EditRotateCommand: EditCommand {
    
    override func perform(_ context: EditCommandContext) {
        guard let context = context as? EditRotateCommandContext else {
            return
        }
        
        guard let videoTrack = composition?.tracks(withMediaType: .video).first else {
            return
        }
        
        let t1 = videoComposition == nil ? CGAffineTransform(translationX: videoTrack.naturalSize.height, y: 0) : CGAffineTransform(translationX: videoComposition!.renderSize.height, y: 0)
        let t2 = t1.rotated(by: context.degress.toRadians())
        
        let instruction: AVMutableVideoCompositionInstruction
        let layerInstruction: AVMutableVideoCompositionLayerInstruction
        if videoComposition == nil {
            videoComposition = AVMutableVideoComposition()
            videoComposition?.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.width)
            videoComposition?.frameDuration = CMTime(value: 1, timescale: 30)
            instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = context.range
            layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            layerInstruction.setTransform(t2, at: .zero)
        } else {
            videoComposition?.renderSize = CGSize(width: videoComposition!.renderSize.height, height: videoComposition!.renderSize.width)
            instruction = videoComposition?.instructions.first! as! AVMutableVideoCompositionInstruction
            layerInstruction = instruction.layerInstructions.first! as! AVMutableVideoCompositionLayerInstruction
            var existingTransform: CGAffineTransform = .identity
            //检查是否已经存在变换
            if layerInstruction.getTransformRamp(for: composition!.duration, start: &existingTransform, end: nil, timeRange: nil) {
                //变换过就在之前的基础上再旋转
                let t = existingTransform.concatenating(t2)
                layerInstruction.setTransform(t, at: .zero)
            } else {
                //没变换过直接赋值
                layerInstruction.setTransform(t2, at: .zero)
            }
        }
        
        //如果要不同timeRange旋转方向不同的话需要用不同的instruction放在
        //videoComposition的instructions里就好
        //暂时只支持整个composition的旋转
        instruction.layerInstructions = [layerInstruction]
        videoComposition?.instructions.append(instruction)
    }
    
}

extension CGFloat {
    
    func toRadians() -> CGFloat {
        return self / 180.0 * .pi
    }
    
}
