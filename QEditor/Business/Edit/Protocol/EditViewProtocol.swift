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
    
    func view(_ view: EditViewInput, didLoadSource urls: [URL])
    
    func viewShouldExportVideo(_ view: EditViewInput)
    
    func exportProject() -> CompositionProjectConfig
    
    func importProject(_ config: CompositionProjectConfig)
    
}
