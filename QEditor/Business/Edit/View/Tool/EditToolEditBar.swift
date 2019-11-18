//
//  EditToolEditBar.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/2.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

protocol EditToolEditBarDelegate: class {
    
    func viewDidSelectedCut(_ view: EditToolEditBar)
    
    func viewDidSelectedDelete(_ view: EditToolEditBar)
    
}

class EditToolEditBar: UICollectionView {
    
    public var backClosure: (() -> Void)?
    
    public weak var selectedDelegate: EditToolEditBarDelegate?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 15
        layout.itemSize = .init(width: 40, height: 50)
        layout.sectionInset = .init(top: 0, left: 30, bottom: 0, right: 0)
        super.init(frame: .zero, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        register(EditToolNormalCell.self, forCellWithReuseIdentifier: "EditToolNormalCell")
        
        addSubview(backButton)
        backButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self).offset(5)
            make.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc
    func didClickBackButton() {
        backClosure?()
    }
    
    lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.addTarget(self, action: #selector(didClickBackButton), for: .touchUpInside)
        view.setImage(UIImage(named: "tool_bar_back"), for: .normal)
        view.backgroundColor = .darkGray
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()

}

extension EditToolEditBar: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditToolNormalCell", for: indexPath) as! EditToolNormalCell
        if indexPath.item == 0 {
            cell.label.text = "分割"
        } else if indexPath.item == 1 {
            cell.label.text = "删除"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.item {
        case 0:
            selectedDelegate?.viewDidSelectedCut(self)
        case 1:
            selectedDelegate?.viewDidSelectedDelete(self)
        default:
            break
        }
    }
    
}
