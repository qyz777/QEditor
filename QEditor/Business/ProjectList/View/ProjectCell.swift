//
//  ProjectCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/18.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import TableViewAdapter

class ProjectCell: UITableViewCell, BaseTableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupSubviews() {
        contentView.addSubview(thumbnailView)
        contentView.addSubview(timeLabel)
        
        thumbnailView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(SCREEN_PADDING_X)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.thumbnailView.snp.right).offset(15)
            make.centerY.equalToSuperview()
        }
    }
    
    func updateCell(with cellModel: BaseTableViewCellModel) {
        guard let cellModel = cellModel as? ProjectCellModel else { return }
        thumbnailView.image = cellModel.config?.videoSegments.first?.thumbnail
        timeLabel.text = cellModel.config?.updateTime
    }
    
    lazy var thumbnailView: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 13)
        return view
    }()

}
