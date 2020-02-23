//
//  EditPlayerInteractionProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation

/// 容器滚动与播放器交互的协议
/// 想要容器具备被播放器调用滚动的逻辑实现协议EditViewPlayProtocol即可
protocol EditPlayerInteractionProtocol {
    
    /// 视图正在被拖动
    /// - Parameter percent: 拖动进度
    func viewIsDraggingWith(with percent: Float)
    
    /// 视图即将开始被拖动
    func viewWillBeginDragging()
    
    /// 视图已经减速结束
    func viewDidEndDecelerating()
    
}
