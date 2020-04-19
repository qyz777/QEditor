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
        return project.videoSegments.count > 1
    }
    
    func toolView(_ toolView: EditToolViewInput, delete segment: CompositionVideoSegment) {
        project.removeVideo(for: segment)
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "删除成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, didSelected videos: [MediaVideoModel], images: [MediaImageModel]) {
        //todo:先只能处理视频了
        guard videos.count > 0 else {
            return
        }
        project.addVideos(from: videos.map({ (model) -> CompositionVideoSegment in
            return CompositionVideoSegment(url: model.url!)
        }))
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "添加成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeSpeedAt segment: CompositionVideoSegment, of scale: Float) {
        beginTaskRunning()
        project.changeSpeed(at: segment, scale: scale)
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "变速视频成功", style: .success)
        endTaskRunning()
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeBrightness value: Float) {
        project.brightness = value
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeExposure value: Float) {
        project.exposure = value
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeContrast value: Float) {
        project.contrast = value
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeSaturation value: Float) {
        project.saturation = value
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }
    
    func toolViewShouldSplitVideo(_ toolView: EditToolViewInput) {
        let time = toolView.currentCursorTime()
        project.splitVideoAt(time: time)
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
        toolView.refreshVideoTransitionView(project.videoSegments)
    }
    
    func toolViewShouldReverseVideo(_ toolView: EditToolViewInput) {
        shouldReverseVideo()
    }
    
    func toolView(_ toolView: EditToolViewInput, didSelectedSplit index: Int, withTransition model: CompositionTransitionModel) {
        project.addTransition(model, at: index)
        refreshView()
        project.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, transitionAt index: Int) -> CompositionTransitionModel {
        guard index < project.videoSegments.count else {
            QELog("通过index获取transition失败")
            return CompositionTransitionModel(duration: 0, style: .none)
        }
        return project.videoSegments[index].transition
    }
    
    func toolView(_ toolView: EditToolViewInput, addMusicFrom asset: AVAsset, title: String?) {
        let currentTime = toolView.currentCursorTime()
        guard let segment = project.addMusic(asset, at: CMTime(seconds: currentTime, preferredTimescale: 600)) else { return }
        segment.title = title
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
        updateMusicCellModels()
        toolView.refreshMusicContainer()
        MessageBanner.show(title: "成功", subTitle: "添加音乐成功", style: .success)
    }
    func toolView(_ toolView: EditToolViewInput, updateMusic segment: CompositionAudioSegment, timeRange: CMTimeRange) {
        project.updateMusic(segment, timeRange: timeRange)
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, replaceMusic oldSegment: CompositionAudioSegment, for newSegment: CompositionAudioSegment) {
        project.replaceMusic(oldSegment: oldSegment, for: newSegment)
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
        toolView.refreshMusicContainer()
    }
    
    func toolView(_ toolView: EditToolViewInput, removeMusic segment: CompositionAudioSegment) {
        project.removeMusic(segment)
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, changeMusic volume: Float, of segment: CompositionAudioSegment) {
        project.updateMusic(segment, volume: volume)
        refreshPlayerViewAndPlay(withAudio: segment)
    }
    
    func toolView(_ toolView: EditToolViewInput, changeMusicFadeIn isOn: Bool, of segment: CompositionAudioSegment) {
        project.updateMusic(segment, isFadeIn: isOn)
        refreshPlayerViewAndPlay(withAudio: segment)
    }
    
    func toolView(_ toolView: EditToolViewInput, changeMusicFadeOut isOn: Bool, of segment: CompositionAudioSegment) {
        project.updateMusic(segment, isFadeOut: isOn)
        refreshPlayerViewAndPlay(withAudio: segment)
    }
    
    func toolView(_ toolView: EditToolViewInput, updateMusic segment: CompositionAudioSegment, atNew start: Double) {
        //todo:处理音乐的边界情况的选中问题
        project.updateMusic(segment, atNew: CMTime(seconds: start, preferredTimescale: 600))
        toolView.refreshMusicContainer()
        refreshPlayerViewAndPlay(withAudio: segment)
    }
    
    func toolView(_ toolView: EditToolViewInput, addRecordAudioFrom asset: AVAsset) {
        let currentTime = toolView.currentCursorTime()
        guard let segment = project.addRecordAudio(asset, at: CMTime(seconds: currentTime, preferredTimescale: 600)) else { return }
        segment.title = "语音录制音频"
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
        
        updateRecordCellModels()
        
        toolView.refreshRecordContainer()
        MessageBanner.show(title: "成功", subTitle: "添加录音成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, updateRecord segment: CompositionAudioSegment, timeRange: CMTimeRange) {
        project.updateRecord(segment, timeRange: timeRange)
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, removeRecord segment: CompositionAudioSegment) {
        project.removeRecord(segment)
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }

    func toolView(_ toolView: EditToolViewInput, changeRecord volume: Float, of segment: CompositionAudioSegment) {
        project.updateRecord(segment, volume: volume)
        refreshPlayerViewAndPlay(withAudio: segment)
    }

    func toolView(_ toolView: EditToolViewInput, changeRecordFadeIn isOn: Bool, of segment: CompositionAudioSegment) {
        project.updateRecord(segment, isFadeIn: isOn)
        refreshPlayerViewAndPlay(withAudio: segment)
    }

    func toolView(_ toolView: EditToolViewInput, changeRecordFadeOut isOn: Bool, of segment: CompositionAudioSegment) {
        project.updateRecord(segment, isFadeOut: isOn)
        refreshPlayerViewAndPlay(withAudio: segment)
    }
    
    func toolViewOriginalAudioEnableMute(_ toolView: EditToolViewInput) {
        project.originVolumn = 0
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }
    
    func toolViewOriginalAudioDisableMute(_ toolView: EditToolViewInput) {
        project.originVolumn = 1.0
        project.reloadPlayer()
        project.seek(to: toolView.currentCursorTime())
    }
    
}

extension EditViewPresenter {
    
    func shouldReverseVideo() {
        guard let segment = toolView?.selectedVideoSegment() else {
            return
        }
        self.beginTaskRunning()
        project.reverseVideo(at: segment) { (error) in
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
    
    func refreshPlayerViewAndPlay(withAudio segment: CompositionAudioSegment) {
        project.reloadPlayer()
        project.seek(to: segment.rangeAtComposition.start.seconds)
        project.play()
    }
    
}
