//
//  MediaPresenter.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import Photos

class MediaPresenter {
    
    public weak var view: (AnyObject & MediaViewInput & MediaPresenterOutput)?
    
    public weak var videoView: (AnyObject & MediaVideoViewInput & MediaPresenterOutput)?
    
    public weak var imageView: (AnyObject & MediaImageViewInput & MediaPresenterOutput)?
    
    private var videoArray: [MediaVideoModel] = []
    
    private var imageArray: [MediaImageModel] = []
    
    private let manager = MediaManager()
    
    init() {
        manager.delegate = self
    }
    
}

extension MediaPresenter: MediaPresenterInput {
    
    func loadVideoModels() {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            return
        }
        manager.fetchAllVideos()
    }
    
    func loadImageModels() {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else {
            return
        }
        manager.fetchAllPhotos()
    }
    
    func loadImage(in asset: PHAsset, _ closure: @escaping (_ image: UIImage?) -> Void) {
        manager.fetchPhoto(in: asset) { (image) in
            closure(image)
        }
    }
    
    func requestAuthorizationIfNeed() {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            return
        }
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                self.loadVideoModels()
                self.loadImageModels()
            case .denied, .restricted:
                self.view?.presenter(self, didAlbumDeniedWithInfo: "未开启相册权限")
            default:
                break
            }
        }
    }
    
}

extension MediaPresenter: MediaVideoViewOutput {
    
    func mediaVideoViewNumberOfItems(_ videoView: MediaVideoViewInput) -> Int {
        return videoArray.count
    }
    
    func mediaVideoView(_ videoView: MediaVideoViewInput, modelAt index: Int) -> MediaVideoModel {
        return videoArray[index]
    }
    
}

extension MediaPresenter: MediaImageViewOutput {
    
    func mediaImageViewNumberOfItems(_ videoView: MediaImageViewInput) -> Int {
        return imageArray.count
    }
       
    func mediaImageView(_ videoView: MediaImageViewInput, modelAt index: Int) -> MediaImageModel {
        return imageArray[index]
    }
    
}

extension MediaPresenter: MediaManagerDelegate {
    
    func didFetchAllPhotos(photos: [MediaImageModel]) {
        imageArray = photos
        imageView?.presenterDidLoadData(self)
    }
    
    func didFetchAllVideos(videos: [MediaVideoModel]) {
        videoArray = videos
        videoView?.presenterDidLoadData(self)
    }
    
}
