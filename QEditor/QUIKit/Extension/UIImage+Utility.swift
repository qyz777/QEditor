//
//  UIImage+Utility.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

public extension Namespace where Base: UIImage {
    
    func convertToSquare() -> UIImage? {
        let length = min(base.size.width, base.size.height)
        let cgImage = base.cgImage
        let centerX = base.size.width / 2
        let centerY = base.size.height / 2
        let rect = CGRect(x: centerX - (length / 2),
                          y: centerY - (length / 2),
                          width: length,
                          height: length)
        let newCgImage = cgImage?.cropping(to: rect)
        guard newCgImage != nil else {
            return nil
        }
        return UIImage(cgImage: newCgImage!)
    }
    
    func scaleToSize(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        base.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let reSizeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    
    func fixOrientation() -> UIImage {
        if base.imageOrientation == .up {
            return base
        }
        
        var transform = CGAffineTransform.identity
        switch base.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: base.size.width, y: base.size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: base.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: base.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
        default:
            break
        }
        
        switch base.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: base.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: base.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        default:
            break
        }
        
        guard let cgImage = base.cgImage else {
            return base
        }
        
        let ctx: CGContext = CGContext(data: nil,
                                       width: Int(base.size.width),
                                       height: Int(base.size.height),
                                       bitsPerComponent: cgImage.bitsPerComponent,
                                       bytesPerRow: 0,
                                       space: cgImage.colorSpace!,
                                       bitmapInfo: cgImage.bitmapInfo.rawValue)!
        ctx.concatenate(transform)
        switch base.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect.init(x: 0, y: 0, width: base.size.height, height: base.size.width))
            break
        default:
            ctx.draw(cgImage, in: CGRect.init(x: 0, y: 0, width: base.size.width, height: base.size.height))
            break
        }
        guard let cgimg: CGImage = ctx.makeImage() else {
            return base
        }
        return UIImage.init(cgImage: cgimg)
    }
    
}
