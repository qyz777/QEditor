//
//  ProjectCellModel.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/18.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import TableViewAdapter

class ProjectCellModel: BaseTableViewCellModel {
    
    let config: CompositionProjectConfig?
    
    var path: String = ""
    
    func cellHeight() -> CGFloat {
        return 100
    }
    
    func cellClassName() -> String {
        return "ProjectCell"
    }
    
    required init(with model: BaseModel?) {
        guard let model = model as? CompositionProjectConfig else {
            config = nil
            return
        }
        config = model
    }
    
}

extension CompositionProjectConfig: BaseModel {}
