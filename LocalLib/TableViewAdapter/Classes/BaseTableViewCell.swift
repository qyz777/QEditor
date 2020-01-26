//
//  BaseTableViewCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/1/26.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  所有Cell必须实现的协议

import Foundation

public protocol BaseTableViewCell {
    
    func updateCell(with cellModel: BaseTableViewCellModel)
    
}
