//
//  EditToolFiltersViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/22.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

let FILTER_CELL_SIZE = (SCREEN_WIDTH - SCREEN_PADDING_X * 2 - 5 * 3) / 4

class EditToolFiltersViewController: EditToolBaseSettingsViewController {
    
    private var cellModels: [EditToolFiltersCellModel] {
        return presenter?.filterCellModels ?? []
    }
    
    private var currentFilterIndex = 0
    
    private let presenter: EditAdjustOutput?
    
    init(presenter: EditAdjustOutput) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
        self.presenter?.adjustView = self
    }
    
    required init?(coder: NSCoder) {
        presenter = nil
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.topBar.snp.bottom)
        }
        
        view.layoutIfNeeded()
        
        presenter?.adjustViewDidLoad()
    }
    
    override func backButtonTouchUpIndside() {
        presenter?.removeSelectedFilter()
        super.backButtonTouchUpIndside()
    }
    
    override func operationDidFinish() {
        presenter?.completeSelected()
        navigationController?.popViewController(animated: true)
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: FILTER_CELL_SIZE, height: FILTER_CELL_SIZE)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        view.contentInset = .init(top: 10, left: SCREEN_PADDING_X, bottom: 10, right: SCREEN_PADDING_X)
        view.delegate = self
        view.dataSource = self
        view.register(cellWithClass: EditToolFilterCell.self)
        return view
    }()

}

extension EditToolFiltersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: EditToolFilterCell.self, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? EditToolFilterCell else { return }
        cell.update(cellModels[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let presenter = presenter else { return }
        currentFilterIndex = indexPath.item
        presenter.filterCellModels = cellModels.map({ (model) -> EditToolFiltersCellModel in
            return EditToolFiltersCellModel(image: model.image, filter: model.filter, selected: false)
        })
        presenter.filterCellModels[currentFilterIndex].selected = true
        presenter.apply(filter: presenter.filterCellModels[currentFilterIndex].filter)
        collectionView.reloadData()
    }
    
}

extension EditToolFiltersViewController: EditAdjustInput {
    
    func refresh() {
        collectionView.reloadData()
    }
    
}

fileprivate class EditToolFilterCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 2
        layer.borderWidth = 1
        layer.borderColor = UIColor.qe.hex(0xFA3E54).cgColor
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: width - 10, height: height - 10))
        }
    }
    
    public func update(_ model: EditToolFiltersCellModel) {
        if model.selected {
            layer.borderWidth = 1
        } else {
            layer.borderWidth = 0
        }
        
        imageView.image = model.image
        imageView.filter = model.filter
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var imageView: CompositionImageView = {
        let view = CompositionImageView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
}
