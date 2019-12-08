//
//  EditToolSettingsView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/30.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

public enum CutSettingsType {
    case split
    case delete
    case changeSpeed
    case reverse
}

public let CUT_SETTINGS_VIEW_HEIGHT: CGFloat = 50

class EditToolCutSettingsView: UICollectionView {

    public var selecctedClosure: ((_ type: CutSettingsType) -> Void)?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 0
        layout.itemSize = .init(width: CUT_SETTINGS_VIEW_HEIGHT * 2, height: CUT_SETTINGS_VIEW_HEIGHT)
        layout.sectionInset = .init(top: 0, left: 30, bottom: 0, right: 0)
        super.init(frame: .zero, collectionViewLayout: layout)
        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
        register(EditToolCutSettingsCell.self, forCellWithReuseIdentifier: "EditToolCutSettingsCell")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

extension EditToolCutSettingsView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditToolCutSettingsCell", for: indexPath) as! EditToolCutSettingsCell
        if indexPath.item == 0 {
            cell.label.text = "分割"
        } else if indexPath.item == 1 {
            cell.label.text = "删除"
        } else if indexPath.item == 2 {
            cell.label.text = "变速"
        } else if indexPath.item == 3 {
            cell.label.text = "反转"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch indexPath.item {
        case 0:
            selecctedClosure?(.split)
        case 1:
            selecctedClosure?(.delete)
        case 2:
            selecctedClosure?(.changeSpeed)
        case 3:
            selecctedClosure?(.reverse)
        default:
            break
        }
    }
    
}

class EditToolCutSettingsCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        backgroundColor = UIColor.qe.hex(0x2F4F4F)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var label: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont.qe.HelveticaBold(size: 13)
        return view
    }()
    
}
