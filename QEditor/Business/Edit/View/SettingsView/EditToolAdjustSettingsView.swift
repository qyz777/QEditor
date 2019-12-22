//
//  EditToolAdjustSettingsView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/21.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolAdjustSettingsView: UICollectionView {
    
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

extension EditToolAdjustSettingsView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditToolSettingsCustomCell", for: indexPath) as! EditToolSettingsCustomCell
        if indexPath.item == 0 {
            cell.label.text = "亮度"
        } else if indexPath.item == 1 {
            cell.label.text = "饱和度"
        } else if indexPath.item == 2 {
            cell.label.text = "对比度"
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch indexPath.item {
        case 0:
            selectedClosure?(.brightness)
        case 1:
            selectedClosure?(.saturation)
        case 2:
            selectedClosure?(.contrast)
        default:
            break
        }
    }
    
}

extension EditToolAdjustSettingsView: EditToolSettingsViewProtocol {
    
    func reload() {
        reloadData()
    }
    
}
