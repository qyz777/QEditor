//
//  AudioFileCellModel.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/25.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import TableViewAdapter

class AudioFileCellModel: BaseTableViewCellModel {
    
    var model: AudioFileModel?
    
    func cellHeight() -> CGFloat {
        return 100
    }
    
    func cellClassName() -> String {
        return "AudioFileCell"
    }
    
    required init(with model: BaseModel?) {
        guard let model = model as? AudioFileModel else {
            return
        }
        self.model = model
    }
    
}
