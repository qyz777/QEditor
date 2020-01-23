//
//  EditToolTabView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//  先简单的用button处理

import UIKit

enum EditToolTabSelectedType {
    case edit
    case music
}

class EditToolTabView: UIView {
    
    var selectedClosure: ((_ type: EditToolTabSelectedType) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(clipButton)
        addSubview(musicButton)
        
        clipButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self.snp.centerX).offset(-50)
        }
        
        musicButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self.snp.centerX).offset(50)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc
    func clipButtonTouchUpInside() {
        selectedClosure?(.edit)
    }
    
    @objc
    func musicButtonTouchUpInside() {
        selectedClosure?(.music)
    }
    
    lazy var clipButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_clip"), for: .normal)
        view.setTitle("剪辑", for: .normal)
        view.addTarget(self, action: #selector(clipButtonTouchUpInside), for: .touchUpInside)
        return view
    }()
    
    lazy var musicButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_music"), for: .normal)
        view.setTitle("音乐", for: .normal)
        view.addTarget(self, action: #selector(musicButtonTouchUpInside), for: .touchUpInside)
        return view
    }()

}
