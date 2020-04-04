//
//  EditToolBar.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/27.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

enum EditToolBarAction {
    case splitVideo
    case deleteVideo
    case videoChangeSpeed
    case videoReverse
    case replaceMusic
    case editMusic
    case deleteMusic
    case editRecord
    case deleteRecord
    case deleteCaption
    case editCaptionStyle
    case editCaption
    case filters
    case brightnessAdjust
    case exposureAdjust
    case contrastAdjust
    case saturationAdjust
}

struct EditToolBarModel {
    let action: EditToolBarAction
    let imageName: String
    let text: String
}

fileprivate let CELL_IDENTIFIER = "EditToolBarCell"

class EditToolBarCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        
        imageView.snp.makeConstraints { (make) in
            make.top.centerX.equalTo(self.contentView)
        }
        
        label.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func update(_ model: EditToolBarModel) {
        imageView.image = UIImage(named: model.imageName)
        label.text = model.text
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.qe.HelveticaBold(size: 11)
        return view
    }()
    
}

class EditToolBar: UICollectionView {
    
    public var selectedClosure: ((_ model: EditToolBarModel) -> Void)?
    
    private var models: [EditToolBarModel] = []

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
        register(EditToolBarCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func update(_ models: [EditToolBarModel]) {
        self.models = models
        reloadData()
    }

}

extension EditToolBar: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as! EditToolBarCell
        cell.update(models[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedClosure?(models[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (SCREEN_WIDTH - 60 - 30 * CGFloat(models.count - 1)) / CGFloat(models.count)
        return CGSize(width: width, height: 60)
    }
    
}
