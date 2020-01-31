//
//  EditToolBaseSettingsViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolBaseSettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(topBar)
        topBar.addSubview(backButton)
        topBar.addSubview(okButton)
        
        topBar.snp.makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.height.equalTo(30)
        }
        
        backButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.topBar).offset(SCREEN_PADDING_X)
            make.centerY.equalTo(self.topBar)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        okButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.topBar).offset(-SCREEN_PADDING_X)
            make.centerY.equalTo(self.topBar)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
    }
    
    open func operationDidFinish() {
        
    }
    
    @objc
    func backButtonTouchUpIndside() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func okButtonTouchUpInside() {
        operationDidFinish()
    }
    
    lazy var topBar: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var backButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_back"), for: .normal)
        view.addTarget(self, action: #selector(backButtonTouchUpIndside), for: .touchUpInside)
        return view
    }()
    
    lazy var okButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_ok"), for: .normal)
        view.addTarget(self, action: #selector(okButtonTouchUpInside), for: .touchUpInside)
        return view
    }()

}
