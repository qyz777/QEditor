//
//  MediaProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol MediaViewInput {
    
}

protocol MediaViewOutput {
    
    func mediaViewShouldCompletion(_ mediaView: MediaViewInput) -> ([MediaVideoModel] ,[MediaImageModel])
    
}

protocol MediaVideoViewInput {
    
}

protocol MediaVideoViewOutput {
    
    func mediaVideoViewNumberOfItems(_ videoView: MediaVideoViewInput) -> Int
    
    func mediaVideoView(_ videoView: MediaVideoViewInput, modelAt index: Int) -> MediaCellModel
    
    func mediaVideoView(_ videoView: MediaVideoViewInput, didSelectAt index: Int)
    
}

protocol MediaImageViewInput {
    
}

protocol MediaImageViewOutput {
    
    func mediaImageViewNumberOfItems(_ imageView: MediaImageViewInput) -> Int
    
    func mediaImageView(_ imageView: MediaImageViewInput, modelAt index: Int) -> MediaCellModel
    
    func mediaImageView(_ imageView: MediaImageViewInput, didSelectAt index: Int)
    
}

protocol MediaPresenterInput {
    
    func loadVideoModels()
    
    func loadImageModels()
    
    func loadImage(in asset: PHAsset, _ closure: @escaping (_ image: UIImage?) -> Void)
    
    func requestAuthorizationIfNeed()
    
    func load(model: MediaVideoModel, _ closure: @escaping () -> Void)
    
}

protocol MediaPresenterOutput {
    
    func presenterDidLoadData(_ presenter: MediaPresenterInput)
    
    func presenter(_ presenter: MediaPresenterInput, didAlbumDeniedWith info: String)
    
    func presenter(_ presenter: MediaPresenterInput, didSelectWith count: Int)
    
}

extension MediaPresenterOutput {
    
    func presenterDidLoadData(_ presenter: MediaPresenterInput) {
        
    }
    
    func presenter(_ presenter: MediaPresenterInput, didAlbumDeniedWith info: String) {
        
    }
    
    func presenter(_ presenter: MediaPresenterInput, didSelectWith count: Int) {
        
    }
    
}
