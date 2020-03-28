//
//  EditToolAudioWaveformView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/24.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import DispatchQueuePool
import AVFoundation

public let WAVEFORM_HEIGHT: CGFloat = 25
fileprivate let CELL_IDENTIFIER = "EditToolWaveformCell"

//以下设置看起来效果比较好
public let HEIGHT_SCALING: CGFloat = 0.9
public let BOX_SAMPLE_WIDTH: Int = 2

class EditToolAudioWaveFormView: UICollectionView {
    
    public var scrollDidEndOffsetXClosure: ((_ offset: CGFloat) -> Void)?
    
    private let queuePool = DispatchQueuePool(name: "AudioWaveFormView.LoadSamples", queueCount: 6, qos: .userInteractive)
    
    private let sampleAnalyzer = AudioSampleAnalyzer()
    
    private var asset: AVAsset?
    
    private var count: Int = 0
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        register(EditToolWaveformCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func update(_ asset: AVAsset) {
        self.asset = asset
        count = Int(ceil(asset.duration.seconds))
        reloadData()
    }
    
    private func drawImage(from samples: [CGFloat], closure: @escaping (_ image: UIImage?) -> Void) {
        let midY = bounds.size.height / 2
        let height = self.height
        queuePool.queue.async {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: EDIT_THUMB_CELL_SIZE, height: height), false, UIScreen.main.scale)
            let context = UIGraphicsGetCurrentContext()
            let topPath = CGMutablePath()
            let bottomPath = CGMutablePath()
            topPath.move(to: .init(x: 0, y: midY))
            bottomPath.move(to: .init(x: 0, y: midY))
            var i = 0
            while i < samples.count {
                let sample = samples[i]
                topPath.addLine(to: CGPoint(x: CGFloat(i * BOX_SAMPLE_WIDTH), y: midY - sample * HEIGHT_SCALING))
                bottomPath.addLine(to: CGPoint(x: CGFloat(i * BOX_SAMPLE_WIDTH), y: midY + sample * HEIGHT_SCALING))
                i += BOX_SAMPLE_WIDTH
            }
            topPath.addLine(to: .init(x: EDIT_THUMB_CELL_SIZE, y: midY))
            bottomPath.addLine(to: .init(x: EDIT_THUMB_CELL_SIZE, y: midY))
            let fullPath = CGMutablePath()
            fullPath.addPath(topPath)
            fullPath.addPath(bottomPath)
            context?.addPath(fullPath)
            //设置填充颜色
            context?.setFillColor(UIColor.qe.hex(0xEEEEEE).cgColor)
            context?.drawPath(using: .fill)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            DispatchQueue.main.async {
                closure(image)
            }
        }
    }

}

extension EditToolAudioWaveFormView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let c = cell as! EditToolWaveformCell
        let height = self.height
        queuePool.queue.async { [weak self] in
            guard let strongSelf = self else { return }
            guard let asset = strongSelf.asset else { return }
            let totalWidth = CGFloat(strongSelf.count) * EDIT_THUMB_CELL_SIZE
            let duration = Double(EDIT_THUMB_CELL_SIZE / totalWidth) * asset.duration.seconds
            let start = Double(EDIT_THUMB_CELL_SIZE * CGFloat(indexPath.item) / totalWidth)
            let simpleData = strongSelf.sampleAnalyzer.readAudioSamples(from: asset, timeRange: CMTimeRange(start: start, end: duration))
            guard simpleData != nil else {
                return
            }
            let samples = strongSelf.sampleAnalyzer.filteredSamples(from: simpleData!, size: CGSize(width: EDIT_THUMB_CELL_SIZE, height: height))
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.drawImage(from: samples) { [weak c] (image) in
                    c?.imageView.image = image
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollDidEndOffsetXClosure?(scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollDidEndOffsetXClosure?(scrollView.contentOffset.x)
        }
    }
    
}

class EditToolWaveformCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
}
