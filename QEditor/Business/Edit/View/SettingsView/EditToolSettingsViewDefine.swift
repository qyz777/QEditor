//
//  EditToolSettingsViewDefine.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

enum EditSettingAction {
    case split
    case delete
    case changeSpeed
    case reverse
    case brightness
    case saturation
}

protocol EditToolSettingsViewProtocol {
    
    func reload()
    
    var selectedClosure: ((_ action: EditSettingAction) -> Void)? { get set }
    
}

let EDIT_TOOL_SETTINGS_VIEW_HEIGHT: CGFloat = 50
let EDIT_TOOL_SETTINGS_CELL_HEIGHT: CGFloat = 40
