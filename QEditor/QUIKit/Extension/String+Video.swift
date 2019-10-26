//
//  String+Video.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/13.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

public extension Namespace where Base == String {
    
    static func formatTime(_ time: Int) -> String {
        let formatTime: String
        if time >= 3600 {
            formatTime = "\(time % 3600)" + ":" + String(format: "%.2d", time / 60) + ":" + String(format: "%.2d", time % 60)
        } else if time >= 60 {
            formatTime = "\(time / 60)" + ":" + String(format: "%.2d", time % 60)
        } else {
            formatTime = "00" + ":" + String(format: "%.2d", time % 60)
        }
        return formatTime
    }
    
}
