//
//  EditViewPresenter+DataSource.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation

extension EditViewPresenter: EditDataSourceProtocol {
    
    func frameCount() -> Int {
        return thumbModels.count
    }
    
    func thumbModel(at index: Int) -> EditToolImageCellModel {
        return thumbModels[index]
    }
    
    func timeContent(at index: Int) -> String {
        let m = thumbModels[index]
        return String.qe.formatTime(Int(m.time.seconds))
    }
    
}
