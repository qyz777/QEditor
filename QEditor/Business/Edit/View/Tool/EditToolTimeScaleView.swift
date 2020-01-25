//
//  EditToolTimeScaleView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/27.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//  时间刻度view

import UIKit

fileprivate let CELL_IDENTIFIER = "EditToolTimeScaleCell"

fileprivate class EditToolTimeScaleCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(leftVView)
        contentView.addSubview(rightVView)
        contentView.addSubview(contentLabel)
        
        leftVView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self.contentView)
            make.width.equalTo(2)
        }
        
        rightVView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(self.contentView)
            make.width.equalTo(2)
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
        }

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var leftVView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        return view
    }()
    
    lazy var rightVView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.qe.HelveticaBold(size: 10)
        return view
    }()
    
}

class EditToolTimeScaleView: UICollectionView {
    
    public var itemCountClosure: (() -> Int)?
    public var itemContentClosure: ((_ item: Int) -> String)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        register(EditToolTimeScaleCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

extension EditToolTimeScaleView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: EDIT_THUMB_CELL_SIZE, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCountClosure?() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as! EditToolTimeScaleCell
        if itemContentClosure != nil {
            cell.contentLabel.text = itemContentClosure?(indexPath.item)
        }
        if indexPath.item == 0 {
            cell.leftVView.isHidden = false
            cell.rightVView.isHidden = true
        } else if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1 {
            cell.leftVView.isHidden = false
            cell.rightVView.isHidden = false
        } else {
            cell.leftVView.isHidden = false
            cell.rightVView.isHidden = true
        }
        return cell
    }
    
}
