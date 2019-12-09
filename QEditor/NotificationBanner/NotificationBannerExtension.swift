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
    
}
