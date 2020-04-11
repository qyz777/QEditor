//
//  EditDataSourceProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation

protocol EditDataSourceProtocol {
    
    var captionCellModels: [EditOperationCaptionCellModel] { get }
    
    var musicCellModels: [EditOperationAudioCellModel] { get }
    
    var recordCellModels: [EditOperationAudioCellModel] { get }
    
    var thumbModels: [EditToolImageCellModel] { get }
    
    var containerContentWidth: CGFloat { get }
    
    /// 获取帧数
    func frameCount() -> Int
    
    /// 获取缩略图cellModel
    /// - Parameter index: 帧下标
    func thumbModel(at index: Int) -> EditToolImageCellModel
    
    /// 获取时间标尺内容
    /// - Parameter index: 帧下标
    func timeContent(at index: Int) -> String
    
    
}
