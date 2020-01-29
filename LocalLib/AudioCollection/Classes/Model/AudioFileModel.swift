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

public class AudioFileModel: BaseModel {
    
    public let item: MPMediaItem
    
    public let assetURL: URL?
    
    public let title: String?
    
    init(item: MPMediaItem) {
        self.item = item
        assetURL = item.assetURL
        title = item.title
    }
    
}
