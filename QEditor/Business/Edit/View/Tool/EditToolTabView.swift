//
//  EditToolTabView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  先简单的用button处理

import UIKit

enum EditToolTabSelectedType {
    case edit
    case music
    case recordAudio
    case text
    case adjust
}

struct EditToolTabCellModel {
    let text: String
    let imageName: String
    let type: EditToolTabSelectedType
}

class EditToolTabView: UICollectionView {
    
    private let datas: [EditToolTabCellModel] = [
        EditToolTabCellModel(text: "剪辑", imageName: "edit_clip", type: .edit),
        EditToolTabCellModel(text: "调节", imageName: "edit_effect_adjust", type: .adjust),
        EditToolTabCellModel(text: "音乐", imageName: "edit_music", type: .music),
        EditToolTabCellModel(text: "录音", imageName: "edit_record_audio", type: .recordAudio),
        EditToolTabCellModel(text: "字幕", imageName: "edit_text", type: .text)
    ]
    
    public var selectedClosure: ((_ type: EditToolTabSelectedType) -> Void)?
    
    init() {
        let frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 40)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 10
        let width = (SCREEN_WIDTH - 10 * CGFloat(datas.count - 1)) / CGFloat(datas.count)
        layout.itemSize = CGSize(width: width, height: 40)
        super.init(frame: frame, collectionViewLayout: layout)
        register(cellWithClass: EditToolTabItemCell.self)
        delegate = self
        dataSource = self
        reloadData()
        layoutIfNeeded()
        if datas.count > 0 {
            addSubview(sliderView)
            let cell = cellForItem(at: IndexPath(item: 0, section: 0))
            let sliderCenterX = cell!.convert(cell!.center, to: self).x
            sliderView.y = frame.maxY - sliderView.height - 2
            sliderView.center.x = sliderCenterX
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private lazy var sliderView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 4))
        view.backgroundColor = UIColor.qe.hex(0xFA3E54)
        view.layer.cornerRadius = 2
        return view
    }()
    
}

extension EditToolTabView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditToolTabItemCell", for: indexPath) as! EditToolTabItemCell
        cell.update(datas[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedClosure?(datas[indexPath.item].type)
        let cell = cellForItem(at: indexPath)
        UIView.animate(withDuration: 0.25) {
            self.sliderView.center.x = cell!.center.x
        }
    }
    
}

fileprivate class EditToolTabItemCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView.snp.centerX).offset(-2)
            make.centerY.equalTo(self.contentView)
        }
        label.snp.makeConstraints { (make) in
            make.left.equalTo(self.contentView.snp.centerX).offset(2)
            make.centerY.equalTo(self.contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func update(_ model: EditToolTabCellModel) {
        label.text = model.text
        imageView.image = UIImage(named: model.imageName)
    }
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
}
