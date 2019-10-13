//
//  MediaCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/7.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class MediaCell: UICollectionViewCell {
    
    public func updateCell(with model: MediaCellModel) {
        if model.imageModel != nil {
            imageView.image = model.imageModel!.image
        } else if model.videoModel != nil {
            imageView.image = model.videoModel!.thumbnail
            timeLabel.isHidden = false
            timeLabel.text = model.videoModel!.formatTime
        }
        selectImageView.isHidden = !model.isSelect
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(self.selectImageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.top.left.equalTo(self.contentView).offset(4)
        }
        selectImageView.snp.makeConstraints { (make) in
            make.right.bottom.equalTo(self.contentView).offset(-5)
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
    
    lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = .systemFont(ofSize: 12)
        view.isHidden = true
        return view
    }()
    
    lazy var selectImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "album_select")
        view.isHidden = true
        return view
    }()
    
}
