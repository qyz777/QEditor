//
//  EditToolAudioWaveformView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/24.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

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
//        backgroundColor = .darkGray
        register(EditToolWaveformCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func update(_ box: [[CGFloat]]) {
        self.box = box
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
        c.update(box[indexPath.item])
    }
    
}
