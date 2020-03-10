//
//  EditCaptionCellToolView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/7.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class EditCaptionCellToolView: UIView {
    
    public var deleteClosure: (() -> Void)?
    public var editClosure: (() -> Void)?
    public var updateClosure: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSuviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupSuviews() {
        addSubview(deleteButton)
        addSubview(editButton)
        addSubview(updateButton)
        
        deleteButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.size.equalTo(CGSize(width: 30, height: 22))
            make.top.bottom.equalToSuperview()
        }
        editButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.deleteButton.snp.right).offset(15)
            make.size.equalTo(CGSize(width: 30, height: 22))
            make.top.bottom.equalToSuperview()
        }
        updateButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.editButton.snp.right).offset(15)
            make.size.equalTo(CGSize(width: 30, height: 22))
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    @objc
    private func deleteButtonTouchUpInside() {
        deleteClosure?()
    }
    
    @objc
    private func editButtonTouchUpInside() {
        editClosure?()
    }
    
    @objc
    private func updateButtonTouchUpInside() {
        updateClosure?()
    }
    
    private lazy var deleteButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.setTitle("删除", for: .normal)
        view.setTitleColor(UIColor.qe.hex(0xEEEEEE), for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        view.addTarget(self, action: #selector(deleteButtonTouchUpInside), for: .touchUpInside)
        return view
    }()
    
    private lazy var editButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.setTitle("样式", for: .normal)
        view.setTitleColor(UIColor.qe.hex(0xEEEEEE), for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        view.addTarget(self, action: #selector(editButtonTouchUpInside), for: .touchUpInside)
        return view
    }()
    
    private lazy var updateButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.setTitle("修改", for: .normal)
        view.setTitleColor(UIColor.qe.hex(0xEEEEEE), for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        view.addTarget(self, action: #selector(updateButtonTouchUpInside), for: .touchUpInside)
        return view
    }()

}
