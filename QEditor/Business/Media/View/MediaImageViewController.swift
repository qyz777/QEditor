//
//  MediaImageViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/7.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

fileprivate let CELL_IDENTIFIER = "MediaCell"

class MediaImageViewController: UIViewController {
    
    public var presenter: (AnyObject & MediaImageViewOutput & MediaPresenterInput)!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        presenter.loadImageModels()
    }
    
    private func initView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: MEDIA_ITEM_SIZE, height: MEDIA_ITEM_SIZE)
        layout.minimumLineSpacing = 11
        layout.minimumInteritemSpacing = SCREEN_PADDING_X
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.contentInset = .init(top: 0, left: SCREEN_PADDING_X, bottom: 0, right: SCREEN_PADDING_X)
        view.register(MediaCell.self, forCellWithReuseIdentifier: CELL_IDENTIFIER)
        view.delegate = self
        view.dataSource = self
        return view
    }()

}

extension MediaImageViewController: MediaPresenterOutput {
    
    func presenterDidLoadData(_ presenter: MediaPresenterInput) {
        collectionView.reloadData()
    }
    
}

extension MediaImageViewController: MediaImageViewInput {
    
    
    
}

extension MediaImageViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.mediaImageViewNumberOfItems(self)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as! MediaCell
        let model = presenter.mediaImageView(self, modelAt: indexPath.item)
        if model.imageModel?.image != nil {
            cell.updateCell(with: model)
        } else {
            presenter.loadImage(in: model.imageModel!.asset!) { (image) in
                model.imageModel!.image = image
                cell.updateCell(with: model)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.mediaImageView(self, didSelectAt: indexPath.item)
    }
    
}
