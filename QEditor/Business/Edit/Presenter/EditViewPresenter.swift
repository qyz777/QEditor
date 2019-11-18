//
//  EditViewPresenter.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//  todo:我觉得这个p太大了，可以拆成子p

import UIKit
import AVFoundation

class EditViewPresenter {
    
    public weak var view: (UIViewController & EditViewInput)!
    
    public weak var playerView: (UIViewController & EditPlayerViewInput & EditViewPresenterOutput)!
    
    public weak var toolView: (UIViewController & EditToolViewInput & EditViewPresenterOutput)!
    
    let toolService = EditToolService()
    
    var thumbModels: [EditToolImageCellModel] = []
    
    func refreshView() {
        guard toolService.videoModel != nil else {
            QELog("EditVideoModel为空")
            return
        }
        //1.派发给player
        playerView.setup(model: toolService.videoModel!)
        //2.处理工具栏数据源
        thumbModels = toolService.split().map({ (time) -> EditToolImageCellModel in
            let m = EditToolImageCellModel()
            m.time = time
            return m
        })
        //3.对外发送加载成功的消息
        playerView.presenter(self, didLoadVideo: toolService.videoModel!)
        toolView.presenter(self, didLoadVideo: toolService.videoModel!)
        //4.刷新工具栏
        toolView.presenterViewShouldReload(self)
    }
    
}

extension EditViewPresenter: EditViewPresenterInput {
    
    func prepare(forVideo model: MediaVideoModel) {
        //交给Service处理成model
        toolService.mediaModel = model
        toolService.generateModels()
        //刷新视图
        refreshView()
    }
    
    func playerShouldPause() {
        playerView.pause()
    }
    
    func playerShouldPlay() {
        playerView.play()
    }
    
}

extension EditViewPresenter: EditViewOutput {
    
}
