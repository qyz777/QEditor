//
//  EditViewPresenter.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class EditViewPresenter {
    
    public weak var view: (UIViewController & EditViewInput)!
    
    public weak var playerView: (UIViewController & EditPlayerViewInput)!
    
    public weak var toolView: (UIViewController & EditToolViewInput & EditViewPresenterOutput)!
    
    let toolService = EditToolService()
    
    var thumbModel: [EditToolImageCellModel] = []
    
}

extension EditViewPresenter: EditViewPresenterInput {
    
    func prepare(forVideo model: MediaVideoModel) {
        //1.派发给player
        playerView.setup(model: model)
        //2.处理工具栏数据源
        toolService.split(video: model) { [weak self] (images) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.thumbModel = images.map { (image) -> EditToolImageCellModel in
                let m = EditToolImageCellModel()
                m.image = image
                return m
            }
            strongSelf.toolView.presenterViewShouldReload(strongSelf)
        }
    }
    
}

extension EditViewPresenter: EditViewOutput {
    
}

extension EditViewPresenter: EditPlayerViewOutput {
    
}
