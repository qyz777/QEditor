//
//  MediaModel.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import Photos

class MediaVideoModel {
    
    var videoTime: CMTime = CMTime()
    var asset: PHAsset?
    var url: URL?
    var formatTime = ""
    var thumbnail: UIImage?
    
}

class MediaImageModel {
    
    var asset: PHAsset?
    var image: UIImage?
    
}
