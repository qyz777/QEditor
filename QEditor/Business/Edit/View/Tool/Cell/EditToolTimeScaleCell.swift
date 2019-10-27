//
//  EditToolTimeScaleCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/27.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolTimeScaleCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(leftVView)
        contentView.addSubview(rightVView)
        contentView.addSubview(contentLabel)
        
        leftVView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self.contentView)
            make.width.equalTo(2)
        }
        
        rightVView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(self.contentView)
            make.width.equalTo(2)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
        }

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var leftVView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        return view
    }()
    
    lazy var rightVView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.qe.HelveticaBold(size: 12)
        return view
    }()
    
}
