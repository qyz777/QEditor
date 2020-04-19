//
//  UIDeviceExtension.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/19.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import DeviceKit

public extension Namespace where Base: UIDevice {
    
    static func isXSeries() -> Bool {
        return Device.allXSeriesDevices.contains(Device.current)
    }
    
}
