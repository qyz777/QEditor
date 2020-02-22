//
//  EditViewPlayProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/7.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

protocol EditViewPlayProtocol {
    
    func loadComposition(_ composition: AVMutableComposition)
    
    func updatePlayTime(_ time: Double)
    
    func updateDuration(_ duration: Double)
    
    func playToEndTime()
    
    func updatePlayViewStatus(_ status: PlayerViewStatus)
    
}

extension EditViewPlayProtocol {
    
    func loadComposition(_ composition: AVMutableComposition) {}
    
    func updatePlayTime(_ time: Double) {}
    
    func updateDuration(_ duration: Double) {}
    
    func playToEndTime() {}
    
    func updatePlayViewStatus(_ status: PlayerViewStatus) {}
    
}
