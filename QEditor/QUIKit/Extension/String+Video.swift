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
    
    /// Document目录
    static func documentPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first ?? NSHomeDirectory() + "/Documents"
    }
    
    /// Library目录
    static func libraryPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.libraryDirectory, .allDomainsMask, true).first ?? NSHomeDirectory() + "/Library"
    }
    
    /// 缓存目录
    static func cachesPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.cachesDirectory, .allDomainsMask, true).first ?? NSHomeDirectory() + "/Library/Caches"
    }
    
    /// Tmp目录
    static func tmpPath() -> String {
        return NSTemporaryDirectory()
    }
    
    /// 时间戳
    static func timestamp() -> String {
        let timeInterval: TimeInterval = NSDate().timeIntervalSince1970
        return "\(Int(timeInterval))"
    }
    
}
