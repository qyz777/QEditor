//
//  EditViewPresenter.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

class EditViewPresenter {
    
    public weak var view: (UIViewController & EditViewInput)?
    
    public weak var playerView: (UIViewController & EditPlayerViewInput)?
    
    public weak var toolView: (UIViewController & EditToolViewInput)?
    
    public weak var addCaptionView: (UIViewController & EditAddCaptionViewInput)?
    
    public weak var editCaptionView: (UIViewController & EditCaptionViewInput)?
    
    public weak var adjustView: (UIViewController & EditAdjustInput)?
    
    public internal(set) var isTaskRunning = false
    
    let project = CompositionProject()
    
    var thumbModels: [EditToolImageCellModel] = []
    
    var captionCellModels: [EditOperationCaptionCellModel] = []
    
    var musicCellModels: [EditOperationAudioCellModel] = []
    
    var recordCellModels: [EditOperationAudioCellModel] = []
    
    var filterCellModels: [EditToolFiltersCellModel] = []
    
    var playerStatus: CompositionPlayerStatus = .unknow
    
    var player: CompositionPlayer {
        return project.player
    }
    
    var duration: TimeInterval {
        return player.duration
    }
    
    var isPlayingBeforeDragging = false
    
    var isEditingCaption: Bool = false
    
    var selectedFilter: CompositionFilter = .none
    
    var currentBrightness: Float {
        return project.brightness
    }
    
    var currentExposure: Float {
        return project.exposure
    }
    
    var currentContrast: Float {
        return project.contrast
    }
    
    var currentSaturation: Float {
        return project.saturation
    }
    
    var containerContentWidth: CGFloat {
        return CGFloat(frameCount()) * EDIT_THUMB_CELL_SIZE
    }
    
    var isMute: Bool {
        return project.originVolumn == 0
    }
    
    init() {
        setupPlayer()
    }
    
    /// 全体数据与以及视图的大刷新
    func refreshView() {
        //1.刷新Composition
        project.refreshComposition()
        guard let composition = project.composition else { return }
        guard let imageSourceComposition = project.imageSourceComposition else { return }
        //2.设置player
        project.reloadPlayer()
        //3.刷新数据源
        loadData()
        //4.刷新工具栏，下面刷新顺序不能乱
        toolView?.refreshOperationContainerView()
        toolView?.loadAsset(imageSourceComposition)
        toolView?.reloadVideoView(project.videoSegments)
        toolView?.refreshVideoTransitionView(project.videoSegments)
        toolView?.refreshWaveFormView(with: composition)
        toolView?.refreshMusicContainer()
        toolView?.refreshRecordContainer()
        toolView?.refreshCaptionContainer()
        //5.恢复到刷新之前的seek
        project.seek(to: toolView?.currentCursorTime() ?? .zero)
    }
    
    public func loadData() {
        thumbModels = splitTime().map({ (time) -> EditToolImageCellModel in
            return EditToolImageCellModel(time: time)
        })
        updateMusicCellModels()
        updateMusicCellModels()
        updateCaptionCellModels()
    }
    
    func beginTaskRunning() {
        isTaskRunning = true
    }
    
    func endTaskRunning() {
        //下一个runloop刷新这个属性
        if isTaskRunning {
            DispatchQueue.main.async {
                self.isTaskRunning = false
            }
        }
    }
    
    func updatePlayerAfterEdit() {
        let lastTime = project.player.playbackTime
        project.reloadPlayer()
        project.seek(to: lastTime)
    }
    
    func splitTime() -> [CMTime] {
        guard let asset = project.composition else { return [] }
        let duration = Int(asset.duration.seconds)
        
        guard duration > 1 else {
            return []
        }

        var times: [CMTime] = []
        for i in 1...duration {
            let time = CMTime(seconds: Double(i), preferredTimescale: 600)
            times.append(time)
        }
        return times
    }
    
    func segmentOffset(for time: Double, in duration: Double) -> CGFloat {
        return CGFloat(Double(containerContentWidth) * time / duration)
    }
    
    func segmentMaxWidth(for duration: Double) -> CGFloat {
        return min(containerContentWidth, segmentOffset(for: duration, in: self.duration))
    }
    
    func updateCaptionCellModels() {
        captionCellModels = project.captionSegments.map({ (segment) -> EditOperationCaptionCellModel in
            let model = EditOperationCaptionCellModel()
            model.width = segmentOffset(for: segment.duration, in: duration)
            model.start = segmentOffset(for: segment.rangeAtComposition.start.seconds, in: duration)
            model.maxWidth = containerContentWidth
            model.content = segment.text
            model.segment = segment
            return model
        })
    }
    
    func updateMusicCellModels() {
        musicCellModels = project.musicSegments.map({ (s) -> EditOperationAudioCellModel in
            return EditOperationAudioCellModel(width: segmentOffset(for: s.duration, in: duration), cellClass: EditOperationAudioCell.self, start: segmentOffset(for: s.rangeAtComposition.start.seconds, in: duration), maxWidth: segmentMaxWidth(for: s.duration), segment: s, title: s.title ?? "")
        })
    }
    
    func updateRecordCellModels() {
        recordCellModels = project.recordAudioSegments.map({ (s) -> EditOperationAudioCellModel in
            return EditOperationAudioCellModel(width: segmentOffset(for: s.duration, in: duration), cellClass: EditOperationAudioCell.self, start: segmentOffset(for: s.rangeAtComposition.start.seconds, in: duration), maxWidth: segmentMaxWidth(for: s.duration), segment: s, title: "语音录制音频")
        })
    }
    
}
