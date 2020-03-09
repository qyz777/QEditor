//
//  EditViewPresenter+AddCaption.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation

extension EditViewPresenter: EditAddCaptionViewOutput {
    
    func setupAddCaptionView(_ view: UIViewController & EditAddCaptionViewInput) {
        addCaptionView = view
    }
    
    func beginAddCaption() {
        addCaptionView?.updateDuration(duration)
        playerView?.play()
    }
    
    func endAddCaption() {
        playerView?.pause()
    }
    
    func addCaptionText(_ text: String?, start: Double, end: Double) {
        playerView?.showEditCaptionView(text: text)
        playerView?.okEditClosure = { [unowned self] (text) in
            let range = CMTimeRange(start: start, end: end)
            self.project.addCaption(text, at: range)
            self.addCaptionView?.update(with: self.project.captionSegments)
            self.updatePlayerAfterEditCaption()
        }
        playerView?.cancelEditClosure = { [unowned self] in
            let range = CMTimeRange(start: start, end: end)
            self.project.addCaption("", at: range)
            self.updatePlayerAfterEditCaption()
        }
    }
    
    func deleteCaption(_ segment: EditCompositionCaptionSegment) {
        project.removeCaption(segment: segment)
        updatePlayerAfterEditCaption()
    }
    
}

extension EditViewPresenter {
    
    func updatePlayerAfterEditCaption() {
        let lastTime = self.playerView?.playbackTime ?? .zero
        self.playerView?.loadComposition(self.project.composition!)
        self.playerView?.seek(to: lastTime)
    }
    
}
