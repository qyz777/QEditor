//
//  ProtocolProxy.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/2/20.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class ProtocolProxy: NSObject, UITableViewDataSource, UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (_interceptor as! UITableViewDataSource).tableView(tableView, numberOfRowsInSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (_interceptor as! UITableViewDataSource).tableView(tableView, cellForRowAt: indexPath)
    }

}
