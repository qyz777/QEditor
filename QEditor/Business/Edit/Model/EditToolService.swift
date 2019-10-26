//
//  EditToolService.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//  fps -> 帧率 每秒的帧数
//  总帧数 = 总时间 * fps

import UIKit
import AVFoundation

class EditToolService {
    
//    private var generator: AVAssetImageGenerator?
//    
//    func loadAsset(_ asset: AVURLAsset) {
//        generator = AVAssetImageGenerator(asset: asset)
//        generator!.requestedTimeToleranceAfter = .zero
//        generator!.requestedTimeToleranceBefore = .zero
//    }
//
//    func split(video model: MediaVideoModel) -> [CMTime] {
//        guard model.url != nil else {
//            return []
//        }
//
//        let asset = AVURLAsset(url: model.url!)
//        let duration = Int(asset.duration.seconds)
//        let needFrames = duration % 30
//        let durationPerFrame = duration / needFrames
//
//        var times: [CMTime] = []
//        for i in 1...durationPerFrame {
//            let time = CMTime(value: CMTimeValue(i * durationPerFrame), timescale: asset.duration.timescale)
//            times.append(time)
//        }
//        return times
//    }
//
//    func loadImage(at time: CMTime, _ closure: @escaping (_ image: UIImage?) -> Void) {
//        guard generator != nil else {
//            closure(nil)
//            return
//        }
//        var image: UIImage?
//        DispatchQueue.global().async {
//            autoreleasepool {
//                do {
//                    let cgImage = try self.generator!.copyCGImage(at: time, actualTime: nil)
//                    image = UIImage(cgImage: cgImage).qe.convertToSquare()
//                } catch {
//                    print(error.localizedDescription)
//                }
//            }
//            DispatchQueue.main.sync {
//                closure(image)
//            }
//        }
//    }
    
    //todo:优化图片加载
    func split(video model: MediaVideoModel, _ closure: @escaping (_ images: [UIImage]) -> Void) {
        guard model.url != nil else {
            closure([])
            return
        }
        
        let asset = AVURLAsset(url: model.url!)
        let duration = Int(asset.duration.seconds)
        let needFrames = duration % 30
        let durationPerFrame = duration / needFrames
        
        var times: [CMTime] = []
        for i in 1...durationPerFrame {
            let time = CMTime(value: CMTimeValue(i * durationPerFrame), timescale: asset.duration.timescale)
            times.append(time)
        }
        
        var images: [UIImage] = []
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        
        DispatchQueue.global().async {
            for time in times {
                autoreleasepool {
                    do {
                        let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
                        let squareImage = UIImage(cgImage: cgImage).qe.convertToSquare()
                        let image = squareImage.qe.scaleToSize(.init(width: EDIT_THUMB_CELL_SIZE, height: EDIT_THUMB_CELL_SIZE))
                        images.append(image)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            DispatchQueue.main.sync {
                closure(images)
            }
        }
    }
    
}
