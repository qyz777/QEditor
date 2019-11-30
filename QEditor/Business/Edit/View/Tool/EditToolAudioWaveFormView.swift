//
//  EditToolAudioWaveformView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/24.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

public let WAVEFORM_HEIGHT: CGFloat = 40

//以下设置看起来效果比较好
fileprivate let WIDTH_SCALING: CGFloat = 0.95
fileprivate let HEIGHT_SCALING: CGFloat = 0.9

fileprivate let CELL_IDENTIFIER = "EditToolWaveformCell"

class EditToolAudioWaveFormView: UICollectionView {
    
    private var box: [[CGFloat]] = []
    
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
    }
    
    private func drawImage(from samples: [CGFloat]) -> UIImage? {
        let maxY = bounds.height
        UIGraphicsBeginImageContext(CGSize(width: EDIT_THUMB_CELL_SIZE, height: WAVEFORM_HEIGHT))
        let path = UIBezierPath()
        path.lineJoinStyle = .round
        path.lineWidth = 1
        var i = 0
        samples.forEach {
            let p = UIBezierPath()
            p.move(to: CGPoint(x: CGFloat(i), y: maxY))
            p.addLine(to: CGPoint(x: CGFloat(i), y: maxY - $0 * HEIGHT_SCALING))
            path.append(p)
            i += 1
        }
        UIColor.qe.hex(0xFF7F24).set()
        path.stroke()
        return UIGraphicsGetImageFromCurrentImageContext()
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
        c.imageView.image = drawImage(from: box[indexPath.item])
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
