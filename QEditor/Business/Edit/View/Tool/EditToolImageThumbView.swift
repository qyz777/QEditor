//
//  EditToolImageThumbView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

let EDIT_THUMB_CELL_SIZE: CGFloat = 80

fileprivate let CELL_IDENTIFIER = "EditToolImageCell"

class EditToolImageThumbView: UICollectionView {
    
    public var itemCountClosure: (() -> Int)?
    public var itemModelClosure: ((_ item: Int) -> EditToolImageCellModel)?
    
    private var generator: AVAssetImageGenerator?
    
    private let queue = DispatchQueue(label: "EditToolService.LoadImage", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    public var videoModel: EditVideoModel? {
        willSet {
            guard newValue != nil else {
                return
            }
            let asset = AVURLAsset(url: newValue!.url)
            generator = AVAssetImageGenerator(asset: asset)
            generator!.requestedTimeToleranceAfter = .zero
            generator!.requestedTimeToleranceBefore = .zero
            //防止获取的图片旋转
            generator!.appliesPreferredTrackTransform = true
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(EditToolImageCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func loadImage(at time: CMTime, _ closure: @escaping (_ image: UIImage?) -> Void) {
        guard generator != nil else {
            closure(nil)
            return
        }
        var image: UIImage?
        queue.async {
            autoreleasepool {
                do {
                    let cgImage = try self.generator!.copyCGImage(at: time, actualTime: nil)
                    image = UIImage(cgImage: cgImage).qe.convertToSquare().qe.scaleToSize(.init(width: EDIT_THUMB_CELL_SIZE, height: EDIT_THUMB_CELL_SIZE))
                } catch {
                    print(error.localizedDescription)
                }
            }
            DispatchQueue.main.sync {
                closure(image)
            }
        }
    }

}

extension EditToolImageThumbView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: EDIT_THUMB_CELL_SIZE, height: EDIT_THUMB_CELL_SIZE)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemCountClosure?() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let c = cell as! EditToolImageCell
        if itemModelClosure != nil {
            let model = itemModelClosure!(indexPath.item)
            loadImage(at: model.time) { (image) in
                c.imageView.image = image
            }
        }
    }
    
}
