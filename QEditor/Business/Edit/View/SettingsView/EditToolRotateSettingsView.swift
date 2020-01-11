//
//  EditToolRotateSettingsView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/4.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class EditToolRotateSettingsView: UIView {
    
    var selectedClosure: ((EditSettingAction) -> Void)?

    init() {
        super.init(frame: .zero)
        addSubview(mirrorButton)
        addSubview(rotateButton)
        mirrorButton.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(100)
            make.centerY.equalTo(self)
        }
        rotateButton.snp.makeConstraints { (make) in
            make.right.equalTo(self).offset(-100)
            make.centerY.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: Action
    @objc
    func didClickLeftButton() {
        selectedClosure?(.mirror)
    }
    
    @objc
    func didClickRotateButton() {
        selectedClosure?(.rotateRight)
    }
    
    lazy var mirrorButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("镜像", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(didClickLeftButton), for: .touchUpInside)
        return view
    }()
    
    lazy var rotateButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("向右", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.addTarget(self, action: #selector(didClickRotateButton), for: .touchUpInside)
        return view
    }()

}

extension EditToolRotateSettingsView: EditToolSettingsViewProtocol {
    
    func reload() {}
    
}
