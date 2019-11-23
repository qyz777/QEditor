//
//  UIViewController+Utillity.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/23.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

public extension Namespace where Base: UIViewController {
    
    class func current(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return current(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return current(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return current(base: presented)
        }
        return base
    }
    
}
