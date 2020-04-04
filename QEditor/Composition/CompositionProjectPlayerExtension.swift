//
//  CompositionProjectPlayerExtension.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/4.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

extension CompositionProject {
    
    public func reloadPlayer() {
        guard let composition = composition else { return }
        stop()
        player.updateAsset(composition, videoComposition: videoComposition, audioMix: audioMix)
    }
    
    public func seek(to time: Double) {
        player.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func stop() {
        player.stop()
    }
    
}
