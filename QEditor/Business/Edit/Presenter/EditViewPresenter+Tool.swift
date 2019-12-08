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
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeSpeedFrom beginTime: Double, to endTime: Double, of scale: Float) {
        let duration = endTime - beginTime
        let scaleDuration = duration * Double(scale)
        let model = EditChangeScaleModel(beginTime: beginTime, endTime: endTime, scaleDuration: scaleDuration)
        toolService.changeSpeed(for: model)
        view?.hiddenSettings()
        refreshView()
    }
    
}

extension EditViewPresenter {
    
    func shouldReverseVideo() {
        guard let tuple = toolView?.forceVideoTimeRange() else {
            return
        }
        let timeRange = CMTimeRange(start: CMTime(seconds: tuple.0, preferredTimescale: 600), end: CMTime(seconds: tuple.1, preferredTimescale: 600))
        toolService.reverseVideo(at: timeRange) { [unowned self] in
            self.refreshView()
        }
    }
    
}
