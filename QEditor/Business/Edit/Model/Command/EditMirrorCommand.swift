//
//  EditMirrorCommand.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/11.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

struct EditMirrorCommandContext: EditCommandContext {
    let range: CMTimeRange
}

class EditMirrorCommand: EditCommand {
    
    override func perform(_ context: EditCommandContext) {
        guard let context = context as? EditMirrorCommandContext else {
            return
        }
        
        guard let videoTrack = composition?.tracks(withMediaType: .video).first else {
            return
        }
        
        let t1 = CGAffineTransform(translationX: videoTrack.naturalSize.width, y: 0)
        let t2 = t1.scaledBy(x: -1, y: 1)
        
        var isNeedReset = false
        let instruction: AVMutableVideoCompositionInstruction
        let layerInstruction: AVMutableVideoCompositionLayerInstruction
        if videoComposition == nil {
            videoComposition = AVMutableVideoComposition()
            videoComposition?.renderSize = videoTrack.naturalSize
            videoComposition?.frameDuration = CMTime(value: 1, timescale: 30)
            instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = context.range
            layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
            layerInstruction.setTransform(t2, at: .zero)
        } else {
            instruction = videoComposition?.instructions.first! as! AVMutableVideoCompositionInstruction
            layerInstruction = instruction.layerInstructions.first! as! AVMutableVideoCompositionLayerInstruction
            var existingTransform: CGAffineTransform = .identity
            if layerInstruction.getTransformRamp(for: composition!.duration, start: &existingTransform, end: nil, timeRange: nil) {
                let t = existingTransform.concatenating(t2)
                layerInstruction.setTransform(t, at: .zero)
                isNeedReset = true
            } else {
                //没变换过直接赋值
                layerInstruction.setTransform(t2, at: .zero)
            }
        }
        
        instruction.layerInstructions = [layerInstruction]
        if isNeedReset {
            for i in 0..<videoComposition!.instructions.count {
                let ins = videoComposition!.instructions[i]
                if ins.timeRange == context.range {
                    videoComposition!.instructions.remove(at: i)
                    break
                }
            }
        }
        videoComposition?.instructions.append(instruction)
    }
    
}
