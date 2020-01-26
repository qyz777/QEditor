//
//  AudioFileModel.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/25.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import TableViewAdapter
import MediaPlayer

class AudioFileModel: BaseModel {
    
    let item: MPMediaItem
    
    init(item: MPMediaItem) {
        self.item = item
    }
    
}
