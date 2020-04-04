//
//  EditPlayerViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/7.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

protocol EditPlayerViewInput: EditViewPlayProtocol {
    
    var okEditClosure: ((_ text: String) -> Void)? { get set }
    
    var cancelEditClosure: (() -> Void)? { get set }
    
    func showEditCaptionView(text: String?)
    
}

protocol EditPlayerViewOutput: class {
    
    var playerStatus: CompositionPlayerStatus { get }
    
    var player: CompositionPlayer { get }
    
}
