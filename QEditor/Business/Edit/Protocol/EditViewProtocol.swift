//
//  EditViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

protocol EditViewInput {
    
}

protocol EditViewOutput: class {
    
}

protocol EditPlayerViewInput {
    
    func setup(model: MediaVideoModel)
    
}

protocol EditPlayerViewOutput: class {
    
}

protocol EditToolViewInput {
    
}

protocol EditToolViewOutput: class {
    
    func toolImageThumbViewItemsCount(_ toolView: EditToolViewInput) -> Int
    
    func toolView(_ toolView: EditToolViewInput, thumbModelAt index: Int) -> EditToolImageCellModel
    
}

protocol EditViewPresenterInput {
    
    func prepare(forVideo model: MediaVideoModel)
    
}

protocol EditViewPresenterOutput: class {
    
    func presenterViewShouldReload(_ presenter: EditViewPresenterInput)
    
}

extension EditViewPresenterOutput {
    
    func presenterViewShouldReload(_ presenter: EditViewPresenterInput) {}
    
}
