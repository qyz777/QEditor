//
//  EditToolSettingsView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/30.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolCutSettingsView: UICollectionView {
    
    var selectedClosure: ((EditSettingAction) -> Void)?
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 0
        layout.itemSize = .init(width: EDIT_TOOL_SETTINGS_VIEW_HEIGHT * 2, height: EDIT_TOOL_SETTINGS_CELL_HEIGHT)
        layout.sectionInset = .init(top: 0, left: 30, bottom: 10, right: 30)
        super.init(frame: .zero, collectionViewLayout: layout)
        showsHorizontalScrollIndicator = false
        delegate = self
        dataSource = self
        register(EditToolSettingsCustomCell.self, forCellWithReuseIdentifier: "EditToolSettingsCustomCell")
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditToolSettingsCustomCell", for: indexPath) as! EditToolSettingsCustomCell
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
            selectedClosure?(.split)
        case 1:
            selectedClosure?(.delete)
        case 2:
            selectedClosure?(.changeSpeed)
        case 3:
            selectedClosure?(.reverse)
        default:
            break
        }
    }
    
}

extension EditToolCutSettingsView: EditToolSettingsViewProtocol {
    
    func reload() {
        reloadData()
    }
    
}
