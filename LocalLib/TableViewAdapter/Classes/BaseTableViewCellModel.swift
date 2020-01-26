//
//  BaseTableViewCellModel.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/1/26.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  所有CellModel必须实现的协议

import Foundation

public protocol BaseTableViewCellModel {
    
    func cellHeight() -> CGFloat
    
    func cellClassName() -> String
    
    init(with model: BaseModel?)
    
}
