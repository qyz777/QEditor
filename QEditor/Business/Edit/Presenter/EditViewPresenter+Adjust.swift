//
//  EditViewPresenter+Adjust.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/22.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import GPUImage

extension EditViewPresenter: EditAdjustOutput {
    
    var compositionPlayer: CompositionPlayer? {
        return playerView?.playerView.player
    }
    
    func adjustViewDidLoad() {
        filterCellModels.removeAll()
        guard let image = project.videoSegments.first?.thumbnail else { return }
        guard let convertImage = image.qe.convertToSquare() else { return }
        let outputImage = convertImage.qe.scaleToSize(CGSize(width: FILTER_CELL_SIZE, height: FILTER_CELL_SIZE))
        //todo:准备空滤镜
        //准备滤镜
        let se = SoftElegance()
        filterCellModels.append(EditToolFiltersCellModel(image: outputImage, filter: se, selected: false))
        let mc = MonochromeFilter()
        filterCellModels.append(EditToolFiltersCellModel(image: outputImage, filter: mc, selected: false))
        let mc1 = MonochromeFilter()
        mc1.color = GPUIMAGE_COLOR(red: 255, green: 235, blue: 205, alpha: 0.2)
        filterCellModels.append(EditToolFiltersCellModel(image: outputImage, filter: mc1, selected: false))
        
        adjustView?.refresh()
    }
    
    func apply(filter: ImageProcessingOperation) {
        guard let player = compositionPlayer else { return }
        guard let filter = copy(filter: filter) else { return }
        if project.selectedFilter != nil {
            player.filters.removeAll {
                return $0 == project.selectedFilter!
            }
        }
        project.selectedFilter = filter
        player.appendFilter(filter)
        updatePlayerAfterEdit()
    }
    
    func removeSelectedFilter() {
        guard let player = compositionPlayer else { return }
        guard let filter = project.selectedFilter else { return }
        player.filters.removeAll {
            return $0 == filter
        }
        project.selectedFilter = nil
        updatePlayerAfterEdit()
    }
    
}

func copy(filter: ImageProcessingOperation) -> ImageProcessingOperation? {
    if let _ = filter as? SoftElegance {
        return SoftElegance()
    } else if let f = filter as? MonochromeFilter {
        let newF = MonochromeFilter()
        newF.color = f.color
        newF.intensity = f.intensity
        return newF
    }
    return nil
}

func GPUIMAGE_COLOR(red: Float, green: Float, blue: Float, alpha: Float) -> Color {
    return Color(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: alpha)
}

func == (lhs: ImageProcessingOperation, rhs: ImageProcessingOperation) -> Bool {
    func _getMemoryFrom(object: AnyObject) -> String {
        let str = Unmanaged<AnyObject>.passUnretained(object).toOpaque()
        return String(describing: str)
    }
    return _getMemoryFrom(object: lhs) == _getMemoryFrom(object: rhs)
}
