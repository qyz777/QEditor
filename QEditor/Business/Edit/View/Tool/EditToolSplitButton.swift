//
//  EditToolSplitButton.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolSplitButton: UIButton {
    
    public var index: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImage(UIImage(named: "edit_split_add"), for: .normal)
        backgroundColor = UIColor(white: 0, alpha: 0.4)
        layer.cornerRadius = 2
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}
