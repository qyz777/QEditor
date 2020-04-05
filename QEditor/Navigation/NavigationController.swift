//
//  NavigationController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
#if DEBUG
import FLEX
#endif

class NavigationController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setValue(NavigationBar(), forKey: "navigationBar")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
        UIApplication.shared.applicationSupportsShakeToEdit = true
        #endif
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        #if DEBUG
        FLEXManager.shared.showExplorer()
        #endif
    }

}
