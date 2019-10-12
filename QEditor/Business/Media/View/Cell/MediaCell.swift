//
//  MediaCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/7.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class MediaCell: UICollectionViewCell {
    
    public func updateCell(with imageModel: MediaImageModel) {
        imageView.image = imageModel.image
    }
    
    public func updateCell(with videoModel: MediaVideoModel) {
        imageView.image = videoModel.thumbnail
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
}
