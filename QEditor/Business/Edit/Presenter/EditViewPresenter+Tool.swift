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
    
    func toolView(_ toolView: EditToolViewInput, delete segment: EditCompositionVideoSegment) {
        project.removeVideo(for: segment)
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "删除成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, needRefreshWaveformViewWith size: CGSize) {
        toolView.refreshWaveFormView(with: project.composition!)
    }
    
    func toolView(_ toolView: EditToolViewInput, didSelected videos: [MediaVideoModel], images: [MediaImageModel]) {
        //todo:先只能处理视频了
        guard videos.count > 0 else {
            return
        }
        project.addVideos(from: videos.map({ (model) -> EditCompositionVideoSegment in
            return EditCompositionVideoSegment(url: model.url!)
        }))
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "添加成功", style: .success)
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeSpeedAt segment: EditCompositionVideoSegment, of scale: Float) {
        beginTaskRunning()
        project.changeSpeed(at: segment, scale: scale)
        refreshView()
        MessageBanner.show(title: "任务", subTitle: "变速视频成功", style: .success)
        endTaskRunning()
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeBrightnessFrom beginTime: Double, to endTime: Double, of value: Float) {
        //todo:预留接口
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeSaturationFrom beginTime: Double, to endTime: Double, of value: Float) {
        //todo:预留接口
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeContrastFrom beginTime: Double, to endTime: Double, of value: Float) {
        //todo:预留接口
    }
    
    func toolView(_ toolView: EditToolViewInput, didChangeGaussianBlurFrom beginTime: Double, to endTime: Double, of value: Float) {
        //todo:预留接口
    }
    
    func toolViewShouldSplitVideo(_ toolView: EditToolViewInput) {
        let time = toolView.currentCursorTime()
        project.splitVideoAt(time: time)
        toolView.refreshView(project.videoSegments)
    }
    
    func toolViewShouldReverseVideo(_ toolView: EditToolViewInput) {
        shouldReverseVideo()
    }
    
    func toolView(_ toolView: EditToolViewInput, didSelectedSplit index: Int, withTransition model: EditTransitionModel) {
        project.addTransition(model, at: index)
        refreshView()
        playerView?.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, transitionAt index: Int) -> EditTransitionModel {
        guard index < project.videoSegments.count else {
            QELog("通过index获取transition失败")
            return EditTransitionModel(duration: 0, style: .none)
        }
        return project.videoSegments[index].transition
    }
    
    func toolView(_ toolView: EditToolViewInput, addMusicFrom asset: AVAsset, title: String?) {
        let currentTime = toolView.currentCursorTime()
        guard let segment = project.addMusic(asset, at: CMTime(seconds: currentTime, preferredTimescale: 600)) else { return }
        segment.title = title
        playerView?.loadComposition(project.composition!)
        playerView?.seek(to: toolView.currentCursorTime())
        toolView.addMusicAudioWaveformView(for: segment)
    }
    func toolView(_ toolView: EditToolViewInput, updateMusic segment: EditCompositionAudioSegment, timeRange: CMTimeRange) {
        //view传来的timeRange是不可信的，在service里还需要校验
        project.updateMusic(segment, timeRange: timeRange)
        playerView?.loadComposition(project.composition!)
        playerView?.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, replaceMusic oldSegment: EditCompositionAudioSegment, for newSegment: EditCompositionAudioSegment) {
        project.replaceMusic(oldSegment: oldSegment, for: newSegment)
        playerView?.loadComposition(project.composition!)
        playerView?.seek(to: toolView.currentCursorTime())
        toolView.refreshMusicWaveformView(with: newSegment)
    }
    
    func toolView(_ toolView: EditToolViewInput, removeMusic segment: EditCompositionAudioSegment) {
        project.removeMusic(segment)
        playerView?.loadComposition(project.composition!)
        playerView?.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, changeMusic volume: Float, of segment: EditCompositionAudioSegment) {
        project.updateMusic(segment, volume: volume)
        refreshPlayerViewAndPlay(withAudio: segment)
    }
    
    func toolView(_ toolView: EditToolViewInput, changeMusicFadeIn isOn: Bool, of segment: EditCompositionAudioSegment) {
        project.updateMusic(segment, isFadeIn: isOn)
        refreshPlayerViewAndPlay(withAudio: segment)
    }
    
    func toolView(_ toolView: EditToolViewInput, changeMusicFadeOut isOn: Bool, of segment: EditCompositionAudioSegment) {
        project.updateMusic(segment, isFadeOut: isOn)
        refreshPlayerViewAndPlay(withAudio: segment)
    }
    
    func toolView(_ toolView: EditToolViewInput, updateMusic segment: EditCompositionAudioSegment, atNew start: Double) {
        //todo:处理音乐的边界情况的选中问题
        project.updateMusic(segment, atNew: CMTime(seconds: start, preferredTimescale: 600))
        toolView.refreshMusicWaveformView(with: segment)
        refreshPlayerViewAndPlay(withAudio: segment)
    }
    
    func toolView(_ toolView: EditToolViewInput, addRecordAudioFrom asset: AVAsset) {
        let currentTime = toolView.currentCursorTime()
        guard let segment = project.addRecordAudio(asset, at: CMTime(seconds: currentTime, preferredTimescale: 600)) else { return }
        segment.title = "语音录制音频"
        playerView?.loadComposition(project.composition!)
        playerView?.seek(to: toolView.currentCursorTime())
        toolView.addRecordAudioWaveformView(for: segment)
    }
    
    func toolView(_ toolView: EditToolViewInput, updateRecord segment: EditCompositionAudioSegment, timeRange: CMTimeRange) {
        project.updateRecord(segment, timeRange: timeRange)
        playerView?.loadComposition(project.composition!)
        playerView?.seek(to: toolView.currentCursorTime())
    }
    
    func toolView(_ toolView: EditToolViewInput, removeRecord segment: EditCompositionAudioSegment) {
        project.removeRecord(segment)
        playerView?.loadComposition(project.composition!)
        playerView?.seek(to: toolView.currentCursorTime())
    }

    func toolView(_ toolView: EditToolViewInput, changeRecord volume: Float, of segment: EditCompositionAudioSegment) {
        project.updateRecord(segment, volume: volume)
        refreshPlayerViewAndPlay(withAudio: segment)
    }

    func toolView(_ toolView: EditToolViewInput, changeRecordFadeIn isOn: Bool, of segment: EditCompositionAudioSegment) {
        project.updateRecord(segment, isFadeIn: isOn)
        refreshPlayerViewAndPlay(withAudio: segment)
    }

    func toolView(_ toolView: EditToolViewInput, changeRecordFadeOut isOn: Bool, of segment: EditCompositionAudioSegment) {
        project.updateRecord(segment, isFadeOut: isOn)
        refreshPlayerViewAndPlay(withAudio: segment)
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
    
    func refreshPlayerViewAndPlay(withAudio segment: EditCompositionAudioSegment) {
        playerView?.loadComposition(project.composition!)
        playerView?.seek(to: segment.rangeAtComposition.start.seconds)
        playerView?.play()
    }
    
}
