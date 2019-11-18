//
//  EditViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

protocol EditViewInput {
    
}

protocol EditViewOutput: class {
    
}

protocol EditPlayerViewInput {
    
    func setup(model: EditVideoModel)
    
    func seek(to percent: Float)
    
    func play()
    
    func pause()
    
}

protocol EditPlayerViewOutput: class {
    
}

protocol EditToolViewInput {
    
}

protocol EditToolViewOutput: class {
    
    func toolImageThumbViewItemsCount(_ toolView: EditToolViewInput) -> Int
    
    func toolView(_ toolView: EditToolViewInput, thumbModelAt index: Int) -> EditToolImageCellModel
    
    /// 工具栏开始横向拖动
    /// - Parameter toolView: 工具栏view
    /// - Parameter percent: 拖动进度
    func toolView(_ toolView: EditToolViewInput, onDragWith percent: Float)
    
    func toolView(_ toolView: EditToolViewInput, contentAt index: Int) -> String
    
    func toolView(_ toolView: EditToolViewInput, deletePartFrom videoParts: [EditToolPartInfo])
    
}

protocol EditViewPresenterInput {
    
    func prepare(forVideo model: MediaVideoModel)
    
    func playerShouldPause()
    
    func playerShouldPlay()
    
}

protocol EditViewPresenterOutput: class {
    
    func presenterViewShouldReload(_ presenter: EditViewPresenterInput)
    
    func presenter(_ presenter: EditViewPresenterInput, didLoadVideo model: EditVideoModel)
    
    //MARK:播放器
    
    func presenter(_ presenter: EditViewPresenterInput, playerDidChange status: AVPlayerItem.Status)
    
    func presenter(_ presenter: EditViewPresenterInput, playerPlayAt time: Double)
    
    func presenter(_ presenter: EditViewPresenterInput, playerDidLoadVideoWith duration: Double)
    
    func presenter(_ presenter: EditViewPresenterInput, playerStatusDidChange status: PlayerViewStatus)
    
    func presenterPlayerDidEndToTime(_ presenter: EditViewPresenterInput)
    
}

extension EditViewPresenterOutput {
    
    func presenterViewShouldReload(_ presenter: EditViewPresenterInput) {}
    
    func presenter(_ presenter: EditViewPresenterInput, didLoadVideo model: EditVideoModel) {}
    
    func presenter(_ presenter: EditViewPresenterInput, playerDidChange status: AVPlayerItem.Status) {}
    
    func presenter(_ presenter: EditViewPresenterInput, playerPlayAt time: Double) {}
    
    func presenter(_ presenter: EditViewPresenterInput, playerDidLoadVideoWith duration: Int64) {}
    
    func presenter(_ presenter: EditViewPresenterInput, playerStatusDidChange status: PlayerViewStatus) {}
    
    func presenterPlayerDidEndToTime(_ presenter: EditViewPresenterInput) {}
    
}
