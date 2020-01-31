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
        let segments = urls.map { (url) -> EditCompositionVideoSegment in
            return EditCompositionVideoSegment(url: url)
        }
        toolService.addVideos(from: segments)
        toolView?.updateDuration(toolService.videoModel!.composition.duration.seconds)
        playerView?.updateDuration(toolService.videoModel!.composition.duration.seconds)
        //刷新视图
        refreshView()
    }
    
}
