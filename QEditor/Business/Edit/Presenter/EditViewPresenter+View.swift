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
    
    func view(_ view: EditViewInput, didLoadSource urls: [URL]) {
        //交给Service处理成model
        let segments = urls.map { (url) -> EditCompositionSegment in
            return EditCompositionSegment(url: url)
        }
        toolService.addVideos(from: segments)
        toolView?.updateDuration(toolService.videoModel!.composition.duration.seconds)
        playerView?.updateDuration(toolService.videoModel!.composition.duration.seconds)
        //刷新视图
        refreshView()
    }
    
//    func view(_ view: EditViewInput, didSelectedSetting action: EditSettingAction) {
//        switch action {
//        case .split:
//            guard let time = toolView?.currentCursorTime() else {
//                return
//            }
//            toolService.splitVideoAt(time: time)
//            toolView?.refreshView(toolService.segments)
//        case .delete:
//            toolView?.deletePart()
//        case .changeSpeed:
//            toolView?.showChangeSpeedView()
//        case .reverse:
//            MessageBanner.show(title: "任务", subTitle: "开始执行反转视频任务", style: .info)
//            shouldReverseVideo()
//        case .brightness:
//            let info = AdjustProgressViewInfo(startValue: -1, endValue: 1, currentValue: toolService.filterService.brightness)
//            toolView?.showChangeBrightnessView(info)
//        case .saturation:
//            let info = AdjustProgressViewInfo(startValue: -30, endValue: 30, currentValue: toolService.filterService.saturation)
//            toolView?.showChangeSaturationView(info)
//        case .contrast:
//            let info = AdjustProgressViewInfo(startValue: -30, endValue: 30, currentValue: toolService.filterService.contrast)
//            toolView?.showChangeContrastView(info)
//        case .gaussianBlur:
//            let info = AdjustProgressViewInfo(startValue: 0, endValue: 20, currentValue: toolService.filterService.gaussianBlur)
//            toolView?.showChangeGaussianBlurView(info)
//        case .rotateRight:
//            let t = toolService.videoModel!.composition.duration
//            let range = CMTimeRange(start: .zero, end: t)
//            let context = EditRotateCommandContext(range: range, degress: 90)
//            toolService.excute(command: .rotate, with: context)
//            playerView?.loadVideoModel(toolService.videoModel!)
//        case .mirror:
//            let t = toolService.videoModel!.composition.duration
//            let range = CMTimeRange(start: .zero, end: t)
//            let context = EditMirrorCommandContext(range: range)
//            toolService.excute(command: .mirror, with: context)
//            playerView?.loadVideoModel(toolService.videoModel!)
//        }
//    }
    
}
