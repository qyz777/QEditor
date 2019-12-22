//
//  EditFilterOperation.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import CoreImage

protocol EditFilterOperation {
    
    var nextOperation: EditFilterOperation? { get set }
    
    func excute(_ filter: CIFilter?, _ context: [String: Any]) -> CIFilter
    
}
