//
//  EditViewPresenter+Tool.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

extension EditViewPresenter: EditToolViewOutput {
    
    func toolImageThumbViewItemsCount(_ toolView: EditToolViewInput) -> Int {
        return thumbModels.count
    }
    
    func toolView(_ toolView: EditToolViewInput, thumbModelAt index: Int) -> EditToolImageCellModel {
        return thumbModels[index]
    }
    
    func toolView(_ toolView: EditToolViewInput, isDraggingWith percent: Float) {
        playerView?.seek(to: percent)
    }
    
    func toolViewWillBeginDragging(_ toolView: EditToolViewInput) {
        isPlayingBeforeDragging = playerStatus == .playing
        //开始拖动时暂停播放器
        playerView?.pause()
    }
    
    func toolViewDidEndDecelerating(_ toolView: EditToolViewInput) {
        if isPlayingBeforeDragging {
            isPlayingBeforeDragging = false
            playerView?.play()
        }
    }
    
    func toolView(_ toolView: EditToolViewInput, contentAt index: Int) -> String {
        let m = thumbModels[index]
        return String.qe.formatTime(Int(m.time.seconds))
    }
    
    func toolView(_ toolView: EditToolViewInput, deletePartFrom info: EditToolPartInfo) {
        let range = CMTimeRange(start: CMTime(seconds: info.beginTime, preferredTimescale: CMTimeScale(600)), end: CMTime(seconds: info.endTime, preferredTimescale: CMTimeScale(600)))
        toolService.removeVideoTimeRange(range)
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "删除成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, needRefreshWaveformViewWith size: CGSize) {
        toolService.loadAudioSamples(for: size, boxCount: thumbModels.count) { (box) in
            self.toolView?.refreshWaveFormView(with: box)
        }
    }
    
    func toolView(_ toolView: EditToolViewInput, shouldShowSettingsFor type: EditSettingType) {
        view?.showSettings(for: type)
    }
    
    func toolView(_ toolView: EditToolViewInput, didSelected videos: [MediaVideoModel], images: [MediaImageModel]) {
        //todo:先只能处理视频了
        guard videos.count > 0 else {
            return
        }
        toolService.addVideos(from: videos)
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "添加成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeSpeedFrom beginTime: Double, to endTime: Double, of scale: Float) {
        beginTaskRunning()
        let duration = endTime - beginTime
        let scaleDuration = duration * Double(scale)
        let model = EditChangeScaleModel(beginTime: beginTime, endTime: endTime, scaleDuration: scaleDuration)
        toolService.changeSpeed(for: model)
        view?.hiddenSettings()
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "变速视频成功", style: .success)
        endTaskRunning()
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeBrightness value: Float) {
        if let composition = toolService.videoModel?.composition {
            let context = [EditFilterBrightnessKey: value]
            let item = filterService.adjust(composition, with: context)
            playerView?.loadPlayerItem(item)
            MessageBanner.show(title: "任务", subTitle: "亮度调节成功", style: .success)
        } else {
            MessageBanner.show(title: "任务", subTitle: "亮度调节失败", style: .warning)
        }
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeSaturation value: Float) {
        if let composition = toolService.videoModel?.composition {
            let context = [EditFilterSaturationKey: value]
            let item = filterService.adjust(composition, with: context)
            playerView?.loadPlayerItem(item)
            MessageBanner.show(title: "任务", subTitle: "饱和度调节成功", style: .success)
        } else {
            MessageBanner.show(title: "任务", subTitle: "饱和度调节失败", style: .warning)
        }
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeContrast value: Float) {
        if let composition = toolService.videoModel?.composition {
            let context = [EditFilterContrastKey: value]
            let item = filterService.adjust(composition, with: context)
            playerView?.loadPlayerItem(item)
            MessageBanner.show(title: "任务", subTitle: "对比度调节成功", style: .success)
        } else {
            MessageBanner.show(title: "任务", subTitle: "对比度调节失败", style: .warning)
        }
    }
    
}

extension EditViewPresenter {
    
    func shouldReverseVideo() {
        guard let tuple = toolView?.forceVideoTimeRange() else {
            return
        }
        self.beginTaskRunning()
        let timeRange = CMTimeRange(start: CMTime(seconds: tuple.0, preferredTimescale: 600), end: CMTime(seconds: tuple.1, preferredTimescale: 600))
        toolService.reverseVideo(at: timeRange) { [unowned self] (error) in
            guard error == nil else {
                MessageBanner.show(title: "任务", subTitle: "反转视频任务失败", style: .danger)
                self.endTaskRunning()
                return
            }
            self.refreshView()
            MessageBanner.show(title: "任务", subTitle: "反转视频任务成功", style: .success)
            self.endTaskRunning()
        }
    }
    
}
