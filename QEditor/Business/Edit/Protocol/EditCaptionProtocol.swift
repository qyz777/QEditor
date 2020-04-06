//
//  EditCaptionProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

protocol EditAddCaptionViewInput: EditViewPlayProtocol {
    
    func refreshCaptionContainerView()
    
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
    
    func deleteCaption(segment: CompositionCaptionSegment)
    
    func updateCaption(segment: CompositionCaptionSegment)
    
    func editCaptionText(for segment: CompositionCaptionSegment)
    
}

protocol EditCaptionViewInput {}

protocol EditCaptionViewOutput: class, EditCaptionInteractionProtocol {
    
    var editCaptionView: (UIViewController & EditCaptionViewInput)? { get set }
    
    func setupEditCaptionView(_ view: UIViewController & EditCaptionViewInput)
    
}
