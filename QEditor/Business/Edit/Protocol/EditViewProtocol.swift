//
//  EditViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

protocol EditViewInput {
    
    func showSettings(for type: EditSettingType)
    
    func hiddenSettings()
    
    func taskWillBegin()
    
    func taskDidComplete()
    
}

protocol EditViewOutput: class {
    
    func view(_ view: EditViewInput, didLoadSource urls: [URL])
    
    func viewWillShowSettings(_ view: EditViewInput)
    
    func viewWillHiddenSettings(_ view: EditViewInput)
    
    func view(_ view: EditViewInput, didSelectedSetting action: EditSettingAction)
    
    func viewIsLoading(_ view: EditViewInput) -> Bool
    
}
