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
        toolView?.updateDuration(asset.duration.seconds)
        playerView?.updateDuration(asset.duration.seconds)
        //刷新视图
        refreshView()
    }
    
    func viewWillShowSettings(_ view: EditViewInput) {
        toolView?.toolBarShouldHidden()
    }
    
    func viewWillHiddenSettings(_ view: EditViewInput) {
        toolView?.toolBarShouldShow()
    }
    
    func view(_ view: EditViewInput, didSelectedSetting action: EditSettingAction) {
        switch action {
        case .split:
            toolView?.split()
        case .delete:
            toolView?.deletePart()
        case .changeSpeed:
            toolView?.showChangeSpeedView()
        case .reverse:
            MessageBanner.show(title: "任务", subTitle: "开始执行反转视频任务", style: .info)
            shouldReverseVideo()
        case .brightness:
            let info = AdjustProgressViewInfo(startValue: -1, endValue: 1, currentValue: filterService.brightness)
            toolView?.showChangeBrightnessView(info)
        case .saturation:
            let info = AdjustProgressViewInfo(startValue: -30, endValue: 30, currentValue: filterService.saturation)
            toolView?.showChangeSaturationView(info)
        case .contrast:
            let info = AdjustProgressViewInfo(startValue: -30, endValue: 30, currentValue: filterService.contrast)
            toolView?.showChangeContrastView(info)
        case .gaussianBlur:
            let info = AdjustProgressViewInfo(startValue: 0, endValue: 20, currentValue: filterService.gaussianBlur)
            toolView?.showChangeGaussianBlurView(info)
        }
    }
    
    func viewIsLoading(_ view: EditViewInput) -> Bool {
        return isTaskRunning
    }
    
}
