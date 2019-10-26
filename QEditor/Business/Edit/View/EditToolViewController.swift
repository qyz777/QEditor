//
//  EditToolViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

fileprivate let CELL_IDENTIFIER = "EditToolImageCell"

class EditToolViewController: UIViewController {
    
    public var presenter: (EditViewPresenterInput & EditToolViewOutput)!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    private func initView() {
        view.backgroundColor = .black
        view.addSubview(containerView)
        containerView.addSubview(contentView)
        contentView.addSubview(thumbView)
        
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.containerView)
            make.height.equalTo(self.containerView)
            make.width.equalTo(self.containerView.contentSize.width)
        }
        
        thumbView.snp.makeConstraints { (make) in
            make.height.equalTo(EDIT_THUMB_CELL_SIZE)
            make.left.right.equalTo(self.contentView)
            make.centerY.equalTo(self.contentView)
        }
    }
    
    private func refreshContainerView() {
        let itemCount = presenter.toolImageThumbViewItemsCount(self)
        containerView.contentSize = .init(width: CGFloat(itemCount) * EDIT_THUMB_CELL_SIZE, height: 0)
        contentView.snp.updateConstraints { (make) in
            make.width.equalTo(self.containerView.contentSize.width)
        }
    }
    
    lazy var containerView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var thumbView: EditToolImageThumbView = {
        let view = EditToolImageThumbView()
        view.isScrollEnabled = false
        view.itemCountClosure = { [weak self] in
            if let ss = self {
                return ss.presenter.toolImageThumbViewItemsCount(ss)
            }
            return 0
        }
        view.itemModelClosure = { [weak self] (item: Int) -> EditToolImageCellModel in
            if let ss = self {
                return ss.presenter.toolView(ss, thumbModelAt: item)
            }
            return EditToolImageCellModel()
        }
        return view
    }()

}

extension EditToolViewController: EditToolViewInput {
    
}

extension EditToolViewController: EditViewPresenterOutput {
    
    func presenterViewShouldReload(_ presenter: EditViewPresenterInput) {
        refreshContainerView()
        thumbView.reloadData()
    }
    
}
