//
//  UIView+Layout.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/27.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

public extension Namespace where Base: UIView {
    
    var left: CGFloat {
        get {
            return base.frame.origin.x
        }
        set(newLeft) {
            var frame = base.frame
            frame.origin.x = newLeft
            base.frame = frame
        }
    }
    
    var top: CGFloat {
        get {
            return base.frame.origin.y
        }
        set(newTop) {
            var frame = base.frame
            frame.origin.y = newTop
            base.frame = frame
        }
    }
    
    var width: CGFloat {
        get {
            return base.frame.size.width
        }
        set(newWidth) {
            var frame = base.frame
            frame.size.width = newWidth
            base.frame = frame
        }
    }
    
    var height: CGFloat {
        get {
            return base.frame.size.height
        }
        set(newHeight) {
            var frame = base.frame
            frame.size.height = newHeight
            base.frame = frame
        }
    }
    
    var right: CGFloat {
        get {
            return base.qe.left + base.qe.width
        }
    }
    
    var bottom: CGFloat {
        get {
            return base.qe.top + base.qe.height
        }
    }
    
    var centerX: CGFloat {
        get {
            return base.center.x
        }
        set(newCenterX) {
            var center = base.center
            center.x = newCenterX
            base.center = center
        }
    }
    
    var centerY: CGFloat {
        get {
            return base.center.y
        }
        set(newCenterY) {
            var center = base.center
            center.y = newCenterY
            base.center = center
        }
    }
    
}
