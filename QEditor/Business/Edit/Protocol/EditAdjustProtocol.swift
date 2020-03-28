//
//  EditAdjustProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/22.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import GPUImage

struct EditToolFiltersCellModel {
    let image: UIImage
    let filter: ImageProcessingOperation
    var selected: Bool
}

protocol EditAdjustInput {
    
    func refresh()
    
}

protocol EditAdjustOutput: class {
    
    var adjustView: (UIViewController & EditAdjustInput)? { get set }
    
    var filterCellModels: [EditToolFiltersCellModel] { get set }
    
    func adjustViewDidLoad()
    
    func apply(filter: ImageProcessingOperation)
    
    func removeSelectedFilter()
    
}
