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
    
    func toolViewCanDeleteAtComposition(_ toolView: EditToolViewInput) -> Bool {
        return toolService.videoSegments.count > 1
    }
    
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
    
    func toolView(_ toolView: EditToolViewInput, delete segment: EditCompositionVideoSegment) {
        toolService.removeVideo(for: segment)
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "删除成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, needRefreshWaveformViewWith size: CGSize) {
        toolService.loadAudioSamples(for: size, boxCount: thumbModels.count) { (box) in
            self.toolView?.refreshWaveFormView(with: box)
        }
    }
    
    func toolView(_ toolView: EditToolViewInput, didSelected videos: [MediaVideoModel], images: [MediaImageModel]) {
        //todo:先只能处理视频了
        guard videos.count > 0 else {
            return
        }
        toolService.addVideos(from: videos.map({ (model) -> EditCompositionVideoSegment in
            return EditCompositionVideoSegment(url: model.url!)
        }))
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "添加成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeSpeedAt segment: EditCompositionVideoSegment, of scale: Float) {
        beginTaskRunning()
        toolService.changeSpeed(at: segment, scale: scale)
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "变速视频成功", style: .success)
        endTaskRunning()
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeBrightnessFrom beginTime: Double, to endTime: Double, of value: Float) {
        let range = CMTimeRange(beginTime: beginTime, endTime: endTime)
        let context = [EditFilterBrightnessKey: (value: value, range: range)]
        toolService.adjustFilter(context)
        playerView?.loadVideoModel(toolService.videoModel!)
        MessageBanner.show(title: "任务", subTitle: "亮度调节成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeSaturationFrom beginTime: Double, to endTime: Double, of value: Float) {
        let range = CMTimeRange(beginTime: beginTime, endTime: endTime)
        let context = [EditFilterSaturationKey: (value: value, range: range)]
        toolService.adjustFilter(context)
        playerView?.loadVideoModel(toolService.videoModel!)
        MessageBanner.show(title: "任务", subTitle: "饱和度调节成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeContrastFrom beginTime: Double, to endTime: Double, of value: Float) {
        let range = CMTimeRange(beginTime: beginTime, endTime: endTime)
        let context = [EditFilterContrastKey: (value: value, range: range)]
        toolService.adjustFilter(context)
        playerView?.loadVideoModel(toolService.videoModel!)
        MessageBanner.show(title: "任务", subTitle: "对比度调节成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeGaussianBlurFrom beginTime: Double, to endTime: Double, of value: Float) {
        let range = CMTimeRange(beginTime: beginTime, endTime: endTime)
        let context = [EditFilterGaussianBlurKey: (value: value, range: range)]
        toolService.adjustFilter(context)
        playerView?.loadVideoModel(toolService.videoModel!)
        MessageBanner.show(title: "任务", subTitle: "模糊调节成功", style: .success)
    }
    
    func toolViewShouldSplitVideo(_ toolView: EditToolViewInput) {
        let time = toolView.currentCursorTime()
        toolService.splitVideoAt(time: time)
        toolView.refreshView(toolService.videoSegments)
    }
    
    func toolViewShouldReverseVideo(_ toolView: EditToolViewInput) {
        MessageBanner.show(title: "任务", subTitle: "开始执行反转视频任务", style: .info)
        shouldReverseVideo()
    }
    
    func toolView(_ toolView: EditToolViewInput, didSelectedSplit index: Int, withTransition model: EditTransitionModel) {
        toolService.addTransition(model, at: index)
        refreshView()
        playerView?.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, transitionAt index: Int) -> EditTransitionModel {
        guard index < toolService.videoSegments.count else {
            QELog("通过index获取transition失败")
            return EditTransitionModel(duration: 0, style: .none)
        }
        return toolService.videoSegments[index].transition
    }
    
    func toolView(_ toolView: EditToolViewInput, addMusicFrom asset: AVAsset) {
        let currentTime = toolView.currentCursorTime()
        guard let segment = toolService.addMusic(asset, at: CMTime(seconds: currentTime, preferredTimescale: 600)) else { return }
        playerView?.loadVideoModel(toolService.videoModel!)
        toolView.addMusicAudioWaveformView(for: segment)
    }
    
}

extension EditViewPresenter {
    
    func shouldReverseVideo() {
        guard let segment = toolView?.forceSegment() else {
            return
        }
        self.beginTaskRunning()
        toolService.reverseVideo(at: segment) { (error) in
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
