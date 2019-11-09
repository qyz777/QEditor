//
//  EditToolPartInfo.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/9.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//  供view使用的视频分段信息模型

import Foundation

class EditToolPartInfo {
    
    weak var chooseView: EditToolChooseBoxView?
    
    var beginTime: Float = 0
    
    var endTime: Float = 0
    
    var duration: Int = 0
    
}
