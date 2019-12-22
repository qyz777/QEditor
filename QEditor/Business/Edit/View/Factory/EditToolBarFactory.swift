//
//  EditToolBarFactory.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

func settingsViewFactoryFor(type: EditSettingType) -> (UIView & EditToolSettingsViewProtocol) {
    switch type {
    case .cut:
        return EditToolCutSettingsView()
    case .adjust:
        return EditToolAdjustSettingsView()
    }
}
