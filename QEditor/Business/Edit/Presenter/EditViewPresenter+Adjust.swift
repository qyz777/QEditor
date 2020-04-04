//
//  EditViewPresenter+Adjust.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/22.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation

extension EditViewPresenter: EditAdjustOutput {
    
    func adjustViewDidLoad() {
        filterCellModels.removeAll()
        guard let image = project.videoSegments.first?.thumbnail else { return }
        guard let convertImage = image.qe.convertToSquare() else { return }
        let outputImage = convertImage.qe.scaleToSize(CGSize(width: FILTER_CELL_SIZE, height: FILTER_CELL_SIZE))
        
        //准备滤镜
        filterCellModels.append(EditToolFiltersCellModel(image: outputImage, filter: .softElegance, selected: false))
        filterCellModels.append(EditToolFiltersCellModel(image: outputImage, filter: .monochrome, selected: false))
        filterCellModels.append(EditToolFiltersCellModel(image: outputImage, filter: .blanchedAlmond, selected: false))
        
        for i in 0..<filterCellModels.count {
            let cm = filterCellModels[i]
            if cm.filter == project.selectedFilter {
                filterCellModels[i].selected = true
                break;
            }
        }
        
        adjustView?.refresh()
    }
    
    func apply(filter: CompositionFilter) {
        project.player.filters.removeAll {
            return $0 == project.selectedFilter
        }
        selectedFilter = filter
        project.player.appendFilter(filter)
        updatePlayerAfterEdit()
    }
    
    func removeSelectedFilter() {
        project.player.filters.removeAll {
            return $0 == selectedFilter
        }
        project.player.appendFilter(project.selectedFilter)
        selectedFilter = .none
        updatePlayerAfterEdit()
    }
    
    func completeSelected() {
        project.selectedFilter = selectedFilter
        selectedFilter = .none
    }
    
}
