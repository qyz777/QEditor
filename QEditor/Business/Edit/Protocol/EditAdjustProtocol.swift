//
//  EditAdjustProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/22.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation

struct EditToolFiltersCellModel {
    let image: UIImage
    let filter: CompositionFilter
    var selected: Bool
}

protocol EditAdjustInput {
    
    func refresh()
    
}

protocol EditAdjustOutput: class {
    
    var adjustView: (UIViewController & EditAdjustInput)? { get set }
    
    var filterCellModels: [EditToolFiltersCellModel] { get set }
    
    func adjustViewDidLoad()
    
    func apply(filter: CompositionFilter)
    
    func removeSelectedFilter()
    
    func completeSelected()
    
}
