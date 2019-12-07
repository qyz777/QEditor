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
    
    let toolService = EditToolService()
    
    var thumbModels: [EditToolImageCellModel] = []
    
    var playerStatus: PlayerViewStatus = .stop
    
    var isPlayingBeforeDragging = false
    
    func refreshView() {
        guard toolService.videoModel != nil else {
            QELog("EditVideoModel为空")
            return
        }
        //1.处理工具栏数据源
        thumbModels = toolService.split().map({ (time) -> EditToolImageCellModel in
            let m = EditToolImageCellModel()
            m.time = time
            return m
        })
        //2.对外发送加载成功的消息
        playerView?.loadVideoModel(toolService.videoModel!)
        toolView?.loadVideoModel(toolService.videoModel!)
        //3.刷新工具栏
        toolView?.reloadView()
    }
    
}
