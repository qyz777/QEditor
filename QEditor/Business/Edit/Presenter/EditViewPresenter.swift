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
    
    var filterCellModels: [EditToolFiltersCellModel] = []
    
    var captionContainerView: EditOperationContainerView?
    
    var playerStatus: PlayerViewStatus = .stop
    
    var isPlayingBeforeDragging = false
    
    var duration: Double = 0
    
    var isEditingCaption: Bool = false
    
    var selectedFilter: CompositionFilter = .none
    
    func refreshView() {
        guard project.composition != nil else {
            QELog("composition为空")
            return
        }
        //1.处理工具栏数据源
        thumbModels = project.splitTime().map({ (time) -> EditToolImageCellModel in
            let m = EditToolImageCellModel()
            m.time = time
            return m
        })
        //2.对外发送加载成功的消息
        playerView?.loadComposition(project.composition!)
        toolView?.loadComposition(project.composition!)
        toolView?.loadAsset(project.imageSourceComposition!)
        //3.刷新工具栏
        toolView?.reloadVideoViews(project.videoSegments)
        //4.恢复到刷新之前的seek
        playerView?.seek(to: toolView?.currentCursorTime() ?? .zero)
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
        guard let composition = project.composition else { return }
        let lastTime = playerView?.playbackTime ?? .zero
        playerView?.loadComposition(composition)
        playerView?.seek(to: lastTime)
    }
    
}
