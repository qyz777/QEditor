//
//  EditToolImageThumbView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation
import DispatchQueuePool

struct EditToolImageCellModel {
    let time: CMTime
}

let EDIT_THUMB_CELL_SIZE: CGFloat = 40

fileprivate class EditToolImageCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.addSublayer(imageLayer)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageLayer.frame = contentView.frame
    }
    
    lazy var imageLayer: CALayer = {
        let layer = CALayer()
        layer.contentsGravity = .resizeAspectFill
        return layer
    }()
    
}

class EditToolImageThumbView: UICollectionView {
    
    public var itemCountClosure: (() -> Int)?
    public var itemModelClosure: ((_ item: Int) -> EditToolImageCellModel)?
    
    private var generator: AVAssetImageGenerator?
    
    private let queuePool = DispatchQueuePool(name: "ImageThumbView.LoadImages", queueCount: 6, qos: .userInteractive)
    
    public var isNeedLoadImageAtDisplay = true
    
    public func loadImages() {
        let items = indexPathsForVisibleItems
        items.forEach {
            let c = cellForItem(at: $0) as! EditToolImageCell
            if itemModelClosure != nil {
                let model = itemModelClosure!($0.item)
                loadImage(at: model.time) { (image) in
                    c.imageLayer.contents = image?.cgImage
                }
            }
        }
    }
    
    public var asset: AVAsset? {
        willSet {
            guard newValue != nil else {
                return
            }
            generator = AVAssetImageGenerator(asset: newValue!)
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
        register(cellWithClass: EditToolImageCell.self)
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
        queuePool.queue.async {
            autoreleasepool {
                do {
                    let cgImage = try self.generator!.copyCGImage(at: time, actualTime: nil)
                    let convertImage = UIImage(cgImage: cgImage).qe.convertToSquare()
                    guard convertImage != nil else {
                        return
                    }
                    image = convertImage!.qe.scaleToSize(.init(width: EDIT_THUMB_CELL_SIZE, height: EDIT_THUMB_CELL_SIZE))
                } catch {
                    QELog(error.localizedDescription)
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
        return itemCountClosure?() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withClass: EditToolImageCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isNeedLoadImageAtDisplay else {
            return
        }
        let c = cell as! EditToolImageCell
        if itemModelClosure != nil {
            let model = itemModelClosure!(indexPath.item)
            loadImage(at: model.time) { (image) in
                c.imageLayer.contents = image?.cgImage
            }
        }
    }
    
}
