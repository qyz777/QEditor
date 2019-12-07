//
//  EditPlayerViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/7.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

protocol EditPlayerViewInput: EditViewPlayProtocol {
    
    func seek(to percent: Float)
    
    func play()
    
    func pause()
    
}

protocol EditPlayerViewOutput: class {
    
}
