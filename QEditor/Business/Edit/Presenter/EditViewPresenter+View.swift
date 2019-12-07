//
//  EditViewPresenter+View.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/30.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

extension EditViewPresenter: EditViewOutput {
    
    func view(_ view: EditViewInput, didLoadMediaVideo model: MediaVideoModel) {
        //交给Service处理成model
        let asset = AVURLAsset(url: model.url!)
        toolService.generateVideoModel(from: [asset])
        //刷新视图
        refreshView()
    }
    
    func viewWillShowSettings(_ view: EditViewInput) {
        toolView?.toolBarShouldHidden()
    }
    
    func viewWillHiddenSettings(_ view: EditViewInput) {
        toolView?.toolBarShouldShow()
    }
    
    func view(_ view: EditViewInput, didSelectedCutType type: CutSettingsType) {
        switch type {
        case .split:
            toolView?.split()
        case .delete:
            toolView?.deletePart()
        }
    }
    
}
