//
//  EditOperationCaptionCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/7.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class EditOperationCaptionCellModel: EditOperationCellModel {
    
    var width: CGFloat = EDIT_OPERATION_VIEW_MIN_WIDTH
    
    var cellClass: AnyClass = EditOperationCaptionCell.self
    
    var start: CGFloat = 0
    
    var maxWidth: CGFloat = EDIT_OPERATION_VIEW_MIN_WIDTH
    
    var content: String = ""
    
    var segment: CompositionCaptionSegment?
    
}

class EditOperationCaptionCell: EditOperationCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 4
        backgroundColor = UIColor.qe.hex(0x222222)
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func update(_ model: EditOperationCellModel) {
        super.update(model)
        guard let model = model as? EditOperationCaptionCellModel else { return }
        contentLabel.text = model.content
    }
    
    private lazy var contentLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 12, weight: .light)
        return view
    }()

}
