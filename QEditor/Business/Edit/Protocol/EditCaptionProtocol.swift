//
//  EditCaptionProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

protocol EditAddCaptionViewInput: EditViewPlayProtocol {
    
    func update(with segments: [EditCompositionCaptionSegment])
    
}

protocol EditAddCaptionViewOutput: class, EditCaptionInteractionProtocol {
    
    var addCaptionView: (UIViewController & EditAddCaptionViewInput)? { get set }
    
    var isEditingCaption: Bool { get }
    
    func setupAddCaptionView(_ view: UIViewController & EditAddCaptionViewInput)
    
    func beginAddCaption()
    
    func endAddCaption()
    
}

protocol EditCaptionInteractionProtocol {
    
    func addCaptionText(_ text: String?, start: Double, end: Double)
    
    func deleteCaption(segment: EditCompositionCaptionSegment)
    
    func updateCaption(segment: EditCompositionCaptionSegment)
    
    func editCaptionText(for segment: EditCompositionCaptionSegment)
    
}

protocol EditCaptionViewInput {}

protocol EditCaptionViewOutput: class, EditCaptionInteractionProtocol {
    
    var editCaptionView: (UIViewController & EditCaptionViewInput)? { get set }
    
    func setupEditCaptionView(_ view: UIViewController & EditCaptionViewInput)
    
}
