//
//  EditTransition.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/24.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  Edit层的指令封装

import Foundation
import AVFoundation

enum EditTransitionStyle {
    case none
    case fadeIn
    case fadeOut
}

struct EditTransitionModel {
    let duration: Double
    let style: EditTransitionStyle
}

class EditTransitionInstruction {
    
    let compositionInstruction: AVMutableVideoCompositionInstruction
    
    var fromLayerInstruction: AVMutableVideoCompositionLayerInstruction?
    
    var toLayerInstruction: AVMutableVideoCompositionLayerInstruction?
    
    let transition: EditTransitionModel
    
    init(instruction: AVMutableVideoCompositionInstruction, transition: EditTransitionModel) {
        compositionInstruction = instruction
        self.transition = transition
    }
    
}

class EditTransitionInstructionBulder {
    
    static func buildInstructions(videoComposition: AVMutableVideoComposition, transitions: [EditTransitionModel]) -> [EditTransitionInstruction] {
        var array: [EditTransitionInstruction] = []
        var layerInstructionIndex = 1
        let compositionInstructions = videoComposition.instructions
        var i = 0
        for vci in compositionInstructions {
            if let vci = vci as? AVMutableVideoCompositionInstruction {
                if vci.layerInstructions.count == 2 {
                    assert(i < transitions.count, "transition数量与instruction数量不匹配")
                    let instruction = EditTransitionInstruction(instruction: vci, transition: transitions[i])
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
