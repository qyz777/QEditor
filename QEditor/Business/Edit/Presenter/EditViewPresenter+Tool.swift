//
//  EditViewPresenter+Tool.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

extension EditViewPresenter: EditToolViewOutput {
    
    func toolImageThumbViewItemsCount(_ toolView: EditToolViewInput) -> Int {
        return thumbModels.count
    }
    
    func toolView(_ toolView: EditToolViewInput, thumbModelAt index: Int) -> EditToolImageCellModel {
        return thumbModels[index]
    }
    
    func toolView(_ toolView: EditToolViewInput, onDragWith percent: Float) {
        playerView?.seek(to: percent)
    }
    
    func toolView(_ toolView: EditToolViewInput, contentAt index: Int) -> String {
        let m = thumbModels[index]
        return String.qe.formatTime(Int(m.time.seconds))
    }
    
    func toolView(_ toolView: EditToolViewInput, deletePartFrom videoParts: [EditToolPartInfo]) {
        let models = videoParts.map { (info) -> EditVideoPartModel in
            return EditVideoPartModel(beginTime: info.beginTime, endTime: info.endTime)
        }
        //todo:删除
        toolService.generateModels(from: models)
        refreshView()
    }
    
}
