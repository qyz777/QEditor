//
//  EditAddCaptionViewProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

protocol EditAddCaptionViewOutput: class {
    
    var addCaptionView: (UIViewController & EditViewPlayProtocol)? { get set }
    
    func setupAddCaptionView(_ view: UIViewController & EditViewPlayProtocol)
    
    func beginAddCaption()
    
    func endAddCaption()
    
}
