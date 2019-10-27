//
//  UIFont+Utility.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/27.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

public extension Namespace where Base: UIFont {
    
    static func HelveticaOblique(size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica-Oblique", size: size)!
    }
    
    static func HelveticaBoldOblique(size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica-BoldOblique", size: size)!
    }
    
    static func Helvetica(size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica", size: size)!
    }
    
    static func HelveticaBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica-Bold", size: size)!
    }
    
}
