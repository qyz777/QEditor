//
//  EditAddCaptionViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

protocol EditAddCaptionViewInput: EditViewPlayProtocol {
    
    func update(with segments: [EditCompositionCaptionSegment])
    
}

protocol EditAddCaptionViewOutput: class {
    
    var addCaptionView: (UIViewController & EditAddCaptionViewInput)? { get set }
    
    func setupAddCaptionView(_ view: UIViewController & EditAddCaptionViewInput)
    
    func beginAddCaption()
    
    func endAddCaption()
    
    func shouldAddCaptionText(_ text: String?, start: Double, end: Double)
    
}
