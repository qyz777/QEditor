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
    
    private var videoCellModelArray: [MediaCellModel] = []
    
    private var imageCellModelArray: [MediaCellModel] = []
    
    private var selectCellModelArray: [MediaCellModel] = []
    
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
    
    func load(model: MediaVideoModel, _ closure: @escaping () -> Void) {
        manager.requestAVAsset(for: model, closure)
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
                self.view?.presenter(self, didAlbumDeniedWith: "未开启相册权限")
            default:
                break
            }
        }
    }
    
}

extension MediaPresenter: MediaViewOutput {
    
    func mediaViewShouldCompletion(_ mediaView: MediaViewInput) -> ([MediaVideoModel] ,[MediaImageModel]) {
        var videos: [MediaVideoModel] = []
        var photos: [MediaImageModel] = []
        for m in selectCellModelArray {
            if m.imageModel != nil {
                photos.append(m.imageModel!)
            } else if m.videoModel != nil {
                videos.append(m.videoModel!)
            }
        }
        return (videos, photos)
    }
    
}

extension MediaPresenter: MediaVideoViewOutput {
    
    func mediaVideoViewNumberOfItems(_ videoView: MediaVideoViewInput) -> Int {
        return videoCellModelArray.count
    }
    
    func mediaVideoView(_ videoView: MediaVideoViewInput, modelAt index: Int) -> MediaCellModel {
        return videoCellModelArray[index]
    }
    
    func mediaVideoView(_ videoView: MediaVideoViewInput, didSelectAt index: Int) {
        videoCellModelArray[index].isSelect = !videoCellModelArray[index].isSelect
        if videoCellModelArray[index].isSelect {
            selectCellModelArray.append(videoCellModelArray[index])
        } else {
            for i in 0..<selectCellModelArray.count {
                let m = selectCellModelArray[i]
                if m == videoCellModelArray[index] {
                    selectCellModelArray.remove(at: i)
                    break
                }
            }
        }
        self.videoView?.presenterDidLoadData(self)
        self.view?.presenter(self, didSelectWith: selectCellModelArray.count)
    }
    
}

extension MediaPresenter: MediaImageViewOutput {
    
    func mediaImageViewNumberOfItems(_ imageView: MediaImageViewInput) -> Int {
        return imageCellModelArray.count
    }
       
    func mediaImageView(_ imageView: MediaImageViewInput, modelAt index: Int) -> MediaCellModel {
        return imageCellModelArray[index]
    }
    
    func mediaImageView(_ imageView: MediaImageViewInput, didSelectAt index: Int) {
        imageCellModelArray[index].isSelect = !imageCellModelArray[index].isSelect
        if imageCellModelArray[index].isSelect {
            selectCellModelArray.append(imageCellModelArray[index])
        } else {
            for i in 0..<selectCellModelArray.count {
                let m = selectCellModelArray[i]
                if m == imageCellModelArray[index] {
                    selectCellModelArray.remove(at: i)
                    break
                }
            }
        }
        self.imageView?.presenterDidLoadData(self)
        self.view?.presenter(self, didSelectWith: selectCellModelArray.count)
    }
    
}

extension MediaPresenter: MediaManagerDelegate {
    
    func didFetchAllPhotos(photos: [MediaImageModel]) {
        imageCellModelArray.removeAll()
        for photo in photos {
            let m = MediaCellModel()
            m.imageModel = photo
            m.isSelect = false
            imageCellModelArray.append(m)
        }
        imageView?.presenterDidLoadData(self)
    }
    
    func didFetchAllVideos(videos: [MediaVideoModel]) {
        videoCellModelArray.removeAll()
        for video in videos {
            let m = MediaCellModel()
            m.videoModel = video
            m.isSelect = false
            videoCellModelArray.append(m)
        }
        videoView?.presenterDidLoadData(self)
    }
    
}
