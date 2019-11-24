//
//  EditToolAudioWaveFormView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/24.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

//以下设置看起来效果比较好
fileprivate let WIDTH_SCALING: CGFloat = 0.95
fileprivate let HEIGHT_SCALING: CGFloat = 0.9
fileprivate let BIN_SIZE_WIDTH: CGFloat = 5

class EditToolAudioWaveFormView: UIView {
    
    private var samples: [CGFloat] = []

    init(frame: CGRect, data: Data) {
        super.init(frame: frame)
        backgroundColor = .darkGray
        samples = filteredSamples(from: data, size: bounds.size)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: HEIGHT_SCALING)
        let yOffset = bounds.size.height - (bounds.size.height * HEIGHT_SCALING)
        context?.translateBy(x: 1, y: yOffset / 2)
        let midY = rect.midY
        let topPath = CGMutablePath()
        let bottomPath = CGMutablePath()
        topPath.move(to: .init(x: 0, y: midY))
        bottomPath.move(to: .init(x: 0, y: midY))
        for i in 0..<samples.count {
            let sample = samples[i]
            topPath.addLine(to: .init(x: CGFloat(i), y: midY - sample))
            bottomPath.addLine(to: .init(x: CGFloat(i), y: midY + sample))
        }
        topPath.addLine(to: .init(x: CGFloat(samples.count), y: midY))
        bottomPath.addLine(to: .init(x: CGFloat(samples.count), y: midY))
        let fullPath = CGMutablePath()
        fullPath.addPath(topPath)
        fullPath.addPath(bottomPath)
        context?.addPath(fullPath)
        //设置填充颜色
        context?.setFillColor(UIColor.lightGray.cgColor)
        context?.drawPath(using: .fill)
    }
    
    /// 过滤音频样本
    /// 数据分箱选出平均数
    /// 这里的粒度要控制好
    private func filteredSamples(from sampleData: Data, size: CGSize) -> [CGFloat] {
        var array: [UInt16] = []
        let sampleCount = sampleData.count / MemoryLayout<UInt16>.size
        let binSize = sampleCount / Int(size.width * BIN_SIZE_WIDTH)
        let bytes: [UInt16] = sampleData.withUnsafeBytes( { bytes in
            let buffer: UnsafePointer<UInt16> = bytes.baseAddress!.assumingMemoryBound(to: UInt16.self)
            return Array(UnsafeBufferPointer(start: buffer, count: sampleData.count / MemoryLayout<UInt16>.size))
        })
        var maxSample: UInt16 = 0
        var i = 0
        while i < sampleCount - binSize {
            var sum: Int = 0
            //获取一箱的平均数，性能又好效果也好
            for j in 0..<binSize {
                sum += Int(bytes[i + j])
            }
            let value = sum / binSize
            array.append(UInt16(value))
            if value > maxSample {
                maxSample = UInt16(value)
            }
            i += binSize
        }
        let scaleFactor = (size.height / 2) / CGFloat(maxSample)
        let res: [CGFloat] = array.map { (a) -> CGFloat in
            return CGFloat(a) * scaleFactor
        }
        return res
    }
    
    /// 取中位数，效果不好
    private func findMidNum(_ samples: [UInt16]) -> UInt16 {
        func _sort(_ array: inout [UInt16], _ start: Int, _ end: Int) -> Int {
            var left = start
            var right = end
            let key = array.last!
            while left < right {
                while left < right && array[left] <= key {
                    left += 1
                }
                while left < right && array[right] >= key {
                    right -= 1
                }
                if left < right {
                    array.swapAt(left, right)
                }
            }
            array.swapAt(right, end)
            return left
        }
        guard samples.count > 0 else {
            return 0
        }
        let start = 0
        let end = samples.count - 1
        let mid = (samples.count - 1) / 2
        var samples = samples
        var div = _sort(&samples, start, end)
        while div != mid {
            if mid < div {
                div = _sort(&samples, start, div - 1)
            } else {
                div = _sort(&samples, div + 1, end)
            }
        }
        return samples[mid]
    }

}
