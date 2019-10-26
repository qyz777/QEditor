//
//  EditToolImageThumbView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/26.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

let EDIT_THUMB_CELL_SIZE: CGFloat = 80

fileprivate let CELL_IDENTIFIER = "EditToolImageCell"

class EditToolImageThumbView: UICollectionView {
    
    public var itemCountClosure: (() -> Int)?
    public var itemModelClosure: ((_ item: Int) -> EditToolImageCellModel)?

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = .init(width: EDIT_THUMB_CELL_SIZE, height: EDIT_THUMB_CELL_SIZE)
        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        register(EditToolImageCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

extension EditToolImageThumbView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemCountClosure?() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as! EditToolImageCell
        if self.itemModelClosure != nil {
            cell.update(with: self.itemModelClosure!(indexPath.item))
        }
        return cell
    }
    
}
