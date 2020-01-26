//
//  AudioDataService.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/25.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioDataService {
    
    public func fetchAudioCollections() -> [AudioCollectionModel] {
        let query = MPMediaQuery()
        return (query.collections ?? []).map { (collection) -> AudioCollectionModel in
            let model = AudioCollectionModel()
            model.thumbnail = collection.items.first?.artwork?.image(at: CGSize(width: AUDIO_COLLECTION_WIDTH, height: AUDIO_COLLECTION_WIDTH))
            model.files = collection.items.map({ (item) -> AudioFileModel in
                return AudioFileModel(item: item)
            })
            return model
        }
    }
    
}
