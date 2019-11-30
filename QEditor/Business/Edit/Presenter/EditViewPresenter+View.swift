//
//  EditViewPresenter+View.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/30.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

extension EditViewPresenter: EditViewOutput {
    
    func viewWillShowSettings(_ view: EditViewInput) {
        toolView?.toolBarShouldHidden()
    }
    
    func viewWillHiddenSettings(_ view: EditViewInput) {
        toolView?.toolBarShouldShow()
    }
    
    func view(_ view: EditViewInput, didSelectedCutType type: CutSettingsType) {
        switch type {
        case .split:
            toolView?.split()
        case .delete:
            toolView?.deletePart()
        }
    }
    
}
