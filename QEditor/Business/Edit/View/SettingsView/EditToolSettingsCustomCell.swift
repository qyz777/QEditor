//
//  EditToolSettingsCustomCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolSettingsCustomCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        backgroundColor = UIColor.qe.hex(0x2F4F4F)
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
