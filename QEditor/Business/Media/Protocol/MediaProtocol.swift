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
    
}

protocol MediaVideoViewInput {
    
}

protocol MediaVideoViewOutput {
    
    func mediaVideoViewNumberOfItems(_ videoView: MediaVideoViewInput) -> Int
    
    func mediaVideoView(_ videoView: MediaVideoViewInput, modelAt index: Int) -> MediaVideoModel
    
}

protocol MediaImageViewInput {
    
}

protocol MediaImageViewOutput {
    
    func mediaImageViewNumberOfItems(_ videoView: MediaImageViewInput) -> Int
    
    func mediaImageView(_ videoView: MediaImageViewInput, modelAt index: Int) -> MediaImageModel
    
}

protocol MediaPresenterInput {
    
    func loadVideoModels()
    
    func loadImageModels()
    
    func loadImage(in asset: PHAsset, _ closure: @escaping (_ image: UIImage?) -> Void)
    
    func requestAuthorizationIfNeed()
    
}

protocol MediaPresenterOutput {
    
    func presenterDidLoadData(_ presenter: MediaPresenterInput)
    
    func presenter(_ presenter: MediaPresenterInput, didAlbumDeniedWithInfo: String)
    
}

extension MediaPresenterOutput {
    
    func presenterDidLoadData(_ presenter: MediaPresenterInput) {
        
    }
    
    func presenter(_ presenter: MediaPresenterInput, didAlbumDeniedWithInfo: String) {
        
    }
    
}
