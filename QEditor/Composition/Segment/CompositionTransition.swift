//
//  CompositionTransition.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/24.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  视频指令的封装

import Foundation
import AVFoundation

public enum CompositionTransitionStyle: String, Codable {
    case none = "none"
    case fadeIn = "fadeIn"
    case fadeOut = "fadeOut"
}

public struct CompositionTransitionModel: Codable {
    let duration: Double
    let style: CompositionTransitionStyle
}

class CompositionTransitionInstruction {
    
    let compositionInstruction: AVMutableVideoCompositionInstruction
    
    var fromLayerInstruction: AVMutableVideoCompositionLayerInstruction?
    
    var toLayerInstruction: AVMutableVideoCompositionLayerInstruction?
    
    let transition: CompositionTransitionModel
    
    init(instruction: AVMutableVideoCompositionInstruction, transition: CompositionTransitionModel) {
        compositionInstruction = instruction
        self.transition = transition
    }
    
}

class CompositionTransitionInstructionBulder {
    
    static func buildInstructions(videoComposition: AVMutableVideoComposition, transitions: [CompositionTransitionModel]) -> [CompositionTransitionInstruction] {
        var array: [CompositionTransitionInstruction] = []
        var layerInstructionIndex = 1
        let compositionInstructions = videoComposition.instructions
        var i = 0
        for vci in compositionInstructions {
            if let vci = vci as? AVMutableVideoCompositionInstruction {
                if vci.layerInstructions.count == 2 {
                    assert(i < transitions.count, "transition数量与instruction数量不匹配")
                    let instruction = CompositionTransitionInstruction(instruction: vci, transition: transitions[i])
                    instruction.fromLayerInstruction = vci.layerInstructions[1 - layerInstructionIndex] as? AVMutableVideoCompositionLayerInstruction
                    instruction.toLayerInstruction = vci.layerInstructions[layerInstructionIndex] as? AVMutableVideoCompositionLayerInstruction
                    array.append(instruction)
                    layerInstructionIndex = layerInstructionIndex == 1 ? 0 : 1
                    i += 1
                }
            }
        }
        return array
    }
    
}
