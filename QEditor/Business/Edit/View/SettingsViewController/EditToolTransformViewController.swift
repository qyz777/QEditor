//
//  EditToolTransformViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/24.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

fileprivate struct EditToolTransitionCellModel {
    let text: String
    let style: CompositionTransitionStyle
    var selected = false
}

class EditToolTransformViewController: EditToolBaseSettingsViewController {
    
    public var selectedClosure: ((_ model: CompositionTransitionModel) -> Void)?
    
    public var currentTransition: CompositionTransitionModel = CompositionTransitionModel(duration: 0, style: .none) {
        willSet {
            guard newValue.duration > 0 else {
                return
            }
            var i = 0
            for model in cellModels {
                if model.style == newValue.style {
                    currentTransitionIndex = i
                    break
                }
                i += 1
            }
            
            cellModels = cellModels.map({ (model) -> EditToolTransitionCellModel in
                return EditToolTransitionCellModel(text: model.text, style: model.style, selected: false)
            })
            cellModels[currentTransitionIndex].selected = true
            collectionView.reloadData()
            for (k, v) in timeIndexInfo {
                if v == newValue.duration {
                    currentTimeIndex = k
                    adjustTimeView.currentIndex = k
                    break
                }
            }
            adjustTimeView.isHidden = currentTransitionIndex == 0
            adjustTimeView.reloadData()
        }
    }
    
    private var currentTransitionIndex: Int = 0
    
    private var currentTimeIndex: Int = 0
    
    private var cellModels: [EditToolTransitionCellModel] = [
        EditToolTransitionCellModel(text: "无", style: .none, selected: false),
        EditToolTransitionCellModel(text: "渐进", style: .fadeIn, selected: false),
        EditToolTransitionCellModel(text: "渐出", style: .fadeOut, selected: false)
    ]
    
    private var timeIndexInfo: [Int: Double] = [
        0: 0.5,
        1: 1.0,
        2: 1.5,
        3: 2.0
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.addSubview(adjustTimeView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topBar.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.adjustTimeView.snp.top)
        }
        adjustTimeView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.view)
            make.height.equalTo(30)
            make.bottom.equalTo(self.view).offset(-10)
        }
        collectionView.reloadData()
        adjustTimeView.reloadData()
    }
    
    override func operationDidFinish() {
        var duration: Double = timeIndexInfo[currentTimeIndex]!
        duration = currentTransitionIndex == 0 ? 0 : duration
        let model = CompositionTransitionModel(duration: duration, style: cellModels[currentTransitionIndex].style)
        selectedClosure?(model)
        navigationController?.popViewController(animated: true)
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (SCREEN_WIDTH - SCREEN_PADDING_X * 2 - 15 * 3) / 4
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        view.contentInset = .init(top: 10, left: SCREEN_PADDING_X, bottom: 10, right: SCREEN_PADDING_X)
        view.delegate = self
        view.dataSource = self
        view.register(EditToolTransformCell.self, forCellWithReuseIdentifier: "EditToolTransformCell")
        return view
    }()
    
    private lazy var adjustTimeView: EditToolTransformAdjustTimeView = {
        let layout = UICollectionViewFlowLayout()
        let width = (SCREEN_WIDTH - SCREEN_PADDING_X * 2 - 15 * 3) / 4
        layout.itemSize = CGSize(width: width, height: 30)
        layout.minimumInteritemSpacing = 15
        layout.minimumLineSpacing = 15
        layout.scrollDirection = .vertical
        let view = EditToolTransformAdjustTimeView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = .init(top: 0, left: SCREEN_PADDING_X, bottom: 0, right: SCREEN_PADDING_X)
        view.isHidden = true
        view.selectedClosure = { [unowned self] (index) in
            self.currentTimeIndex = index
        }
        return view
    }()

}

extension EditToolTransformViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditToolTransformCell", for: indexPath) as! EditToolTransformCell
        cell.update(cellModels[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentTransitionIndex = indexPath.item
        cellModels = cellModels.map({ (model) -> EditToolTransitionCellModel in
            return EditToolTransitionCellModel(text: model.text, style: model.style, selected: false)
        })
        cellModels[currentTransitionIndex].selected = true
        collectionView.reloadData()
        adjustTimeView.isHidden = indexPath.item == 0
    }
    
}

fileprivate class EditToolTransformCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.qe.hex(0xFA3E54).cgColor
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: frame.size.width - 10, height: frame.size.width - 10))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.containerView)
        }
    }
    
    public func update(_ model: EditToolTransitionCellModel) {
        titleLabel.text = model.text
        if model.selected {
            layer.borderWidth = 1
        } else {
            layer.borderWidth = 0
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.backgroundColor = UIColor.qe.hex(0xFA3E54)
        return view
    }()
    
}

fileprivate class EditToolTransformAdjustTimeView: UICollectionView {
    
    public var selectedClosure: ((_ index: Int) -> Void)?
    
    var currentIndex: Int = 0
    
    private let times: [String] = [
        "0.5s",
        "1.0s",
        "1.5s",
        "2.0s"
    ]
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        dataSource = self
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        register(EditToolTransformAdjustTimeCell.self, forCellWithReuseIdentifier: "EditToolTransformAdjustTimeCell")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension EditToolTransformAdjustTimeView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return times.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EditToolTransformAdjustTimeCell", for: indexPath) as! EditToolTransformAdjustTimeCell
        cell.titleLabel.text = times[indexPath.item]
        if indexPath.item == currentIndex {
            cell.layer.borderWidth = 1
        } else {
            cell.layer.borderWidth = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedClosure?(indexPath.item)
        currentIndex = indexPath.item
        reloadData()
    }
    
}

fileprivate class EditToolTransformAdjustTimeCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 2
        layer.borderColor = UIColor.darkGray.cgColor
        layer.borderWidth = 1
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: frame.size.width - 5, height: frame.size.height - 5))
            make.center.equalTo(self.contentView)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.containerView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.backgroundColor = .darkGray
        return view
    }()
    
}
