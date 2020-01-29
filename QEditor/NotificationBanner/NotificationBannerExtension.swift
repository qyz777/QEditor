//
//  NotificationBannerExtension.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/9.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation
import NotificationBannerSwift

fileprivate let bannerQueueToDisplaySeveralBanners = NotificationBannerQueue(maxBannersOnScreenSimultaneously: 3)

class MessageBanner {
    
    static func show(title: String, subTitle: String? = nil, style: BannerStyle = .info) {
        let banner = FloatingNotificationBanner.init(title: title, subtitle: subTitle, style: style)
        banner.duration = 1.5
        banner.haptic = .light
        banner.show(queue: bannerQueueToDisplaySeveralBanners, on: UIViewController.qe.current()?.navigationController, cornerRadius: 8)
    }
    
    static func success(content: String) {
        show(title: "成功", subTitle: content, style: .success)
    }
    
    static func warning(content: String) {
        show(title: "警告", subTitle: content, style: .warning)
    }
    
    static func info(content: String) {
        show(title: "提示", subTitle: content, style: .info)
    }
    
    static func error(content: String) {
        show(title: "错误", subTitle: content, style: .danger)
    }
    
}
