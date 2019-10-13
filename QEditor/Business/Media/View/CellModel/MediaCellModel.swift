//
//  MediaCellModel.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/13.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

class MediaCellModel: Equatable {
    
    var videoModel: MediaVideoModel?
    
    var imageModel: MediaImageModel?
    
    var isSelect = false
    
    static func == (lhs: MediaCellModel, rhs: MediaCellModel) -> Bool {
        if lhs.imageModel != nil && rhs.imageModel != nil {
            if lhs.imageModel!.image != nil && rhs.imageModel!.image != nil {
                return lhs.imageModel!.image!.isEqual(rhs.imageModel!.image!)
            } else {
                return false
            }
        } else if lhs.videoModel != nil && rhs.videoModel != nil {
            if lhs.videoModel!.thumbnail != nil && rhs.videoModel!.thumbnail != nil {
                return lhs.videoModel!.thumbnail!.isEqual(rhs.videoModel!.thumbnail!)
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
}
