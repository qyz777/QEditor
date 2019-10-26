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
    
    var thumbModel: [EditToolImageCellModel] = []
    
}

extension EditViewPresenter: EditViewPresenterInput {
    
    func prepare(forVideo model: MediaVideoModel) {
        //1.派发给player
        playerView.setup(model: model)
        //2.处理工具栏数据源
        thumbModel = toolService.split(video: model).map({ (time) -> EditToolImageCellModel in
            let m = EditToolImageCellModel()
            m.time = time
            return m
        })
        //3.对外发送加载成功的消息
        playerView.presenter(self, didLoadVideo: model)
        toolView.presenter(self, didLoadVideo: model)
        //4.刷新工具栏
        toolView.presenterViewShouldReload(self)
    }
    
}

extension EditViewPresenter: EditViewOutput {
    
}
