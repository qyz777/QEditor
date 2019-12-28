//
//  EditToolAudioWaveformView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/24.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

public let WAVEFORM_HEIGHT: CGFloat = 40
fileprivate let CELL_IDENTIFIER = "EditToolWaveformCell"

//以下设置看起来效果比较好
fileprivate let HEIGHT_SCALING: CGFloat = 0.5
public let BOX_SAMPLE_WIDTH: CGFloat = 5

class EditToolAudioWaveFormView: UICollectionView {
    
    private var box: [[CGFloat]] = []
    
    private let queue = DispatchQueue(label: "AudioWaveFormView.LoadSamples", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        register(EditToolWaveformCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func update(_ box: [[CGFloat]]) {
        self.box = box
        reloadData()
    }
    
    private func drawImage(from samples: [CGFloat], closure: @escaping (_ image: UIImage?) -> Void) {
        let midY = bounds.size.height / 2
        queue.async {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: EDIT_THUMB_CELL_SIZE, height: WAVEFORM_HEIGHT), false, UIScreen.main.scale)
            let context = UIGraphicsGetCurrentContext()
            let topPath = CGMutablePath()
            let bottomPath = CGMutablePath()
            topPath.move(to: .init(x: 0, y: midY))
            bottomPath.move(to: .init(x: 0, y: midY))
            for i in 0..<samples.count {
                let sample = samples[i]
                topPath.addLine(to: CGPoint(x: CGFloat(i) * BOX_SAMPLE_WIDTH, y: midY - sample * HEIGHT_SCALING))
                bottomPath.addLine(to: CGPoint(x: CGFloat(i) * BOX_SAMPLE_WIDTH, y: midY + sample * HEIGHT_SCALING))
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
        return box.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let c = cell as! EditToolWaveformCell
        drawImage(from: box[indexPath.item]) { (image) in
            c.imageView.image = image
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
