//
//  EditToolAddMusicButton.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/25.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolAddMusicButton: UIControl {

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
        textLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(self)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        view.text = "添加音乐"
        return view
    }()

}
