//
//  EditToolNormalCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/2.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolNormalCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.qe.HelveticaBold(size: 13)
        return view
    }()
    
}
