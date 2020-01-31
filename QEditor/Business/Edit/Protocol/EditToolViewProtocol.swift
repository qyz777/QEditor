//
//  EditToolViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/7.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

protocol EditToolViewInput: EditViewPlayProtocol {
    
    func refreshWaveFormView(with asset: AVAsset)
    
    func deletePart()
    
    func reloadView(_ segments: [EditCompositionVideoSegment])
    
    func refreshView(_ segments: [EditCompositionVideoSegment])
    
    func showChangeBrightnessView(_ info: AdjustProgressViewInfo)
    
    func showChangeSaturationView(_ info: AdjustProgressViewInfo)
    
    func showChangeContrastView(_ info: AdjustProgressViewInfo)
    
    func showChangeGaussianBlurView(_ info: AdjustProgressViewInfo)
    
    func selectedVideoSegment() -> EditCompositionVideoSegment?
    
    /// 当前标尺所指的视频位置
    func currentCursorTime() -> Double
    
    func loadAsset(_ asset: AVAsset)
    
    func addMusicAudioWaveformView(for segment: EditCompositionAudioSegment)
    
    func refreshMusicWaveformView(with segment: EditCompositionAudioSegment)
    
    func addRecordAudioWaveformView(for segment: EditCompositionAudioSegment)
    
}

protocol EditToolViewOutput: class {
    
    func toolViewCanDeleteAtComposition(_ toolView: EditToolViewInput) -> Bool
    
    func toolImageThumbViewItemsCount(_ toolView: EditToolViewInput) -> Int
    
    func toolView(_ toolView: EditToolViewInput, thumbModelAt index: Int) -> EditToolImageCellModel
    
    /// 工具栏正在被横向拖动
    /// - Parameter toolView: 工具栏view
    /// - Parameter percent: 拖动进度
    func toolView(_ toolView: EditToolViewInput, isDraggingWith percent: Float)
    
    func toolViewWillBeginDragging(_ toolView: EditToolViewInput)
    
    func toolViewDidEndDecelerating(_ toolView: EditToolViewInput)
    
    func toolView(_ toolView: EditToolViewInput, contentAt index: Int) -> String
    
    func toolView(_ toolView: EditToolViewInput, delete segment: EditCompositionVideoSegment)
    
    func toolView(_ toolView: EditToolViewInput, needRefreshWaveformViewWith size: CGSize)
    
    func toolView(_ toolView: EditToolViewInput, didSelected videos: [MediaVideoModel], images: [MediaImageModel])
    
    func toolView(_ toolView: EditToolViewInput, didChangeSpeedAt segment: EditCompositionVideoSegment, of scale: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeBrightnessFrom beginTime: Double, to endTime: Double, of value: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeSaturationFrom beginTime: Double, to endTime: Double, of value: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeContrastFrom beginTime: Double, to endTime: Double, of value: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeGaussianBlurFrom beginTime: Double, to endTime: Double, of value: Float)
    
    func toolViewShouldSplitVideo(_ toolView: EditToolViewInput)
    
    func toolViewShouldReverseVideo(_ toolView: EditToolViewInput)
    
    func toolView(_ toolView: EditToolViewInput, didSelectedSplit index: Int, withTransition model: EditTransitionModel)
    
    func toolView(_ toolView: EditToolViewInput, transitionAt index: Int) -> EditTransitionModel
    
    func toolView(_ toolView: EditToolViewInput, addMusicFrom asset: AVAsset, title: String?)
    
    func toolView(_ toolView: EditToolViewInput, updateMusic segment: EditCompositionAudioSegment, timeRange: CMTimeRange)
    
    func toolView(_ toolView: EditToolViewInput, replaceMusic oldSegment: EditCompositionAudioSegment, for newSegment: EditCompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, removeMusic segment: EditCompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, change volume: Float, of segment: EditCompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, changeFadeIn isOn: Bool, of segment: EditCompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, changeFadeOut isOn: Bool, of segment: EditCompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, updateMusic segment: EditCompositionAudioSegment, atNew start: Double)
    
    func toolView(_ toolView: EditToolViewInput, addRecordAudioFrom asset: AVAsset)
    
}
