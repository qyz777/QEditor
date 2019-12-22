//
//  EditToolViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/7.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

protocol EditToolViewInput: EditViewPlayProtocol {
    
    func refreshWaveFormView(with sampleBox: [[CGFloat]])
    
    func toolBarShouldHidden()
    
    func toolBarShouldShow()
    
    func split()
    
    func deletePart()
    
    func reloadView()
    
    func showChangeSpeedView()
    
    func showChangeBrightnessView(_ info: AdjustProgressViewInfo)
    
    func showChangeSaturationView(_ info: AdjustProgressViewInfo)
    
    func showChangeContrastView(_ info: AdjustProgressViewInfo)
    
    func forceVideoTimeRange() -> (start: Double, end: Double)
    
}

protocol EditToolViewOutput: class {
    
    func toolImageThumbViewItemsCount(_ toolView: EditToolViewInput) -> Int
    
    func toolView(_ toolView: EditToolViewInput, thumbModelAt index: Int) -> EditToolImageCellModel
    
    /// 工具栏正在被横向拖动
    /// - Parameter toolView: 工具栏view
    /// - Parameter percent: 拖动进度
    func toolView(_ toolView: EditToolViewInput, isDraggingWith percent: Float)
    
    func toolViewWillBeginDragging(_ toolView: EditToolViewInput)
    
    func toolViewDidEndDecelerating(_ toolView: EditToolViewInput)
    
    func toolView(_ toolView: EditToolViewInput, contentAt index: Int) -> String
    
    func toolView(_ toolView: EditToolViewInput, deletePartFrom info: EditToolPartInfo)
    
    func toolView(_ toolView: EditToolViewInput, needRefreshWaveformViewWith size: CGSize)
    
    func toolView(_ toolView: EditToolViewInput, shouldShowSettingsFor type: EditSettingType)
    
    func toolView(_ toolView: EditToolViewInput, didSelected videos: [MediaVideoModel], images: [MediaImageModel])
    
    func toolView(_ toolView: EditToolViewInput, didChangeSpeedFrom beginTime: Double, to endTime: Double, of scale: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeBrightness value: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeSaturation value: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeContrast value: Float)
    
}
