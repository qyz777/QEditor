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
    
    /// 视频相关view的重新加载，会重新reload视频片段以及原声音频片段
    /// - Parameter segments: 视频segment
    func reloadVideoViews(_ segments: [CompositionVideoSegment])
    
    /// 视频相关view的刷新，不会reload视频片段以及原声音频片段
    /// - Parameter segments: 视频segment
    func refreshVideoViews(_ segments: [CompositionVideoSegment])
    
    func selectedVideoSegment() -> CompositionVideoSegment?
    
    /// 当前标尺所指的视频位置
    func currentCursorTime() -> Double
    
    func loadAsset(_ asset: AVAsset)
    
    func addMusicAudioWaveformView(for segment: CompositionAudioSegment)
    
    func refreshMusicWaveformView(with segment: CompositionAudioSegment)
    
    func addRecordAudioWaveformView(for segment: CompositionAudioSegment)
    
}

protocol EditToolViewOutput: class, EditDataSourceProtocol, EditPlayerInteractionProtocol, EditCaptionInteractionProtocol {
    
    var currentBrightness: Float { get }
    
    var currentExposure: Float { get }
    
    var currentContrast: Float { get }
    
    var currentSaturation: Float { get }
    
    func toolViewCanDeleteAtComposition(_ toolView: EditToolViewInput) -> Bool
    
    func toolView(_ toolView: EditToolViewInput, delete segment: CompositionVideoSegment)
    
    func toolView(_ toolView: EditToolViewInput, needRefreshWaveformViewWith size: CGSize)
    
    func toolView(_ toolView: EditToolViewInput, didSelected videos: [MediaVideoModel], images: [MediaImageModel])
    
    func toolView(_ toolView: EditToolViewInput, didChangeSpeedAt segment: CompositionVideoSegment, of scale: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeBrightness value: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeExposure value: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeContrast value: Float)
    
    func toolView(_ toolView: EditToolViewInput, didChangeSaturation value: Float)
    
    func toolViewShouldSplitVideo(_ toolView: EditToolViewInput)
    
    func toolViewShouldReverseVideo(_ toolView: EditToolViewInput)
    
    func toolView(_ toolView: EditToolViewInput, didSelectedSplit index: Int, withTransition model: CompositionTransitionModel)
    
    func toolView(_ toolView: EditToolViewInput, transitionAt index: Int) -> CompositionTransitionModel
    
    //MARK: Music
    
    func toolView(_ toolView: EditToolViewInput, addMusicFrom asset: AVAsset, title: String?)
    
    func toolView(_ toolView: EditToolViewInput, updateMusic segment: CompositionAudioSegment, timeRange: CMTimeRange)
    
    func toolView(_ toolView: EditToolViewInput, replaceMusic oldSegment: CompositionAudioSegment, for newSegment: CompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, removeMusic segment: CompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, changeMusic volume: Float, of segment: CompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, changeMusicFadeIn isOn: Bool, of segment: CompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, changeMusicFadeOut isOn: Bool, of segment: CompositionAudioSegment)
    
    func toolView(_ toolView: EditToolViewInput, updateMusic segment: CompositionAudioSegment, atNew start: Double)
    
    //MARK: Record
    
    func toolView(_ toolView: EditToolViewInput, addRecordAudioFrom asset: AVAsset)
    
    func toolView(_ toolView: EditToolViewInput, updateRecord segment: CompositionAudioSegment, timeRange: CMTimeRange)
    
    func toolView(_ toolView: EditToolViewInput, removeRecord segment: CompositionAudioSegment)

    func toolView(_ toolView: EditToolViewInput, changeRecord volume: Float, of segment: CompositionAudioSegment)

    func toolView(_ toolView: EditToolViewInput, changeRecordFadeIn isOn: Bool, of segment: CompositionAudioSegment)

    func toolView(_ toolView: EditToolViewInput, changeRecordFadeOut isOn: Bool, of segment: CompositionAudioSegment)
    
}
