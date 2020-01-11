//
//  EditCommand.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/4.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  Model层新体系，未来需要将原有逻辑切换为此模式

import Foundation
import AVFoundation

/// 执行需要传递的参数
protocol EditCommandContext {}

class EditCommand {
    
    var composition: AVMutableComposition?
    var videoComposition: AVMutableVideoComposition?
    
    required init() {}
    
    public func perform(_ context: EditCommandContext) {
        assert(false, "perform(_:)方法必须被重写!")
    }
    
}
