//
//  EditPlayerViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/7.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

protocol EditPlayerViewInput: EditViewPlayProtocol {
    
    var okEditClosure: ((_ text: String) -> Void)? { get set }
    
    var cancelEditClosure: (() -> Void)? { get set }
    
    var playbackTime: TimeInterval { get }
    
    var playerView: EditPlayerView { get }
    
    func seek(to percent: Float)
    
    func seek(to time: Double)
    
    func play()
    
    func pause()
    
    func showEditCaptionView(text: String?)
    
}

protocol EditPlayerViewOutput: class {
    
}
