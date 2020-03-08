//
//  EditPlayerCaptionTextField.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/8.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class EditPlayerCaptionTextField: UIView {
    
    public var okClosure: (() -> Void)?
    
    public var cancelClosure: (() -> Void)?
    
    public var text: String? {
        set {
            textField.text = newValue
        }
        get {
            return textField.text
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSuviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    public func clear() {
        textField.text = nil
    }
    
    private func setupSuviews() {
        addSubview(okButton)
        addSubview(cancelButton)
        addSubview(textField)
        cancelButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
        }
        textField.snp.makeConstraints { (make) in
            make.left.equalTo(self.cancelButton.snp.right).offset(15)
            make.width.equalTo(SCREEN_WIDTH / 3 * 2)
            make.height.equalTo(30)
            make.top.bottom.equalToSuperview()
        }
        okButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.textField.snp.right).offset(15)
            make.right.top.bottom.equalToSuperview()
        }
    }
    
    @objc
    private func okButtonTouchUpInside() {
        okClosure?()
    }
    
    @objc
    private func cancelButtonTouchUpInside() {
        clear()
        cancelClosure?()
    }
    
    private lazy var okButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_caption_ok"), for: .normal)
        view.addTarget(self, action: #selector(okButtonTouchUpInside), for: .touchUpInside)
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_red_cancel"), for: .normal)
        view.addTarget(self, action: #selector(cancelButtonTouchUpInside), for: .touchUpInside)
        return view
    }()
    
    private lazy var textField: UITextField = {
        let view = UITextField()
        view.contentHorizontalAlignment = .center
        view.layer.borderColor = UIColor.qe.hex(0xEEEEEE).cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 2
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 13)
        view.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        view.leftViewMode = .always
        view.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        view.rightViewMode = .always
        view.attributedPlaceholder = NSAttributedString(string:"输入字幕", attributes: [NSAttributedString.Key.foregroundColor: UIColor.qe.hex(0xC0C0C0), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
        return view
    }()

}
