//
//  BaseProxy.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/2/20.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class BaseProxy: NSObject {
    
    private weak var _target: AnyObject?
    private weak var _interceptor: AnyObject?
    
    override func responds(to aSelector: Selector!) -> Bool {
        return _target?.responds(to: aSelector) ?? false || _interceptor?.responds(to: aSelector) ?? false
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if _target?.responds(to: aSelector) ?? false {
            return _target
        } else if _interceptor?.responds(to: aSelector) ?? false {
            return _interceptor
        }
        return super.responds(to: aSelector)
    }
    
    init(with target: AnyObject?, for interceptor: AnyObject?) {
        super.init()
        _target = target
        _interceptor = interceptor
    }

}
