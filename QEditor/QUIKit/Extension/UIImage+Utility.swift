//
//  UIImage+Utility.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

public extension Namespace where Base: UIImage {
    
    func convertToSquare() -> UIImage {
        let length = min(base.size.width, base.size.height)
        let cgImage = base.cgImage
        let centerX = base.size.width / 2
        let centerY = base.size.height / 2
        let rect = CGRect(x: centerX - (length / 2),
                          y: centerY - (length / 2),
                          width: length,
                          height: length)
        let newCgImage = cgImage!.cropping(to: rect)
        return UIImage(cgImage: newCgImage!)
    }
    
    func scaleToSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        base.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
}
