//
//  EditViewPresenter+Tool.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

extension EditViewPresenter: EditToolViewOutput {
    
    func toolImageThumbViewItemsCount(_ toolView: EditToolViewInput) -> Int {
        return thumbModel.count
    }
    
    func toolView(_ toolView: EditToolViewInput, thumbModelAt index: Int) -> EditToolImageCellModel {
        return thumbModel[index]
    }
    
}
