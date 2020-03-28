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
        let segments = urls.map { (url) -> CompositionVideoSegment in
            return CompositionVideoSegment(url: url)
        }
        project.addVideos(from: segments)
        toolView?.updateDuration(project.composition!.duration.seconds)
        playerView?.updateDuration(project.composition!.duration.seconds)
        //刷新视图
        refreshView()
    }
    
}
