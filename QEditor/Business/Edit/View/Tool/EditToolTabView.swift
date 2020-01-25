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
        addSubview(sliderView)
        
        clipButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.right.equalTo(self.snp.centerX).offset(-50)
        }
        
        musicButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.left.equalTo(self.snp.centerX).offset(50)
        }
        
        sliderView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.clipButton)
            make.bottom.equalTo(self).offset(-2)
            make.size.equalTo(CGSize(width: 30, height: 4))
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc
    func clipButtonTouchUpInside(_ button: UIButton) {
        selectedClosure?(.edit)
        UIView.animate(withDuration: 0.25) {
            self.sliderView.snp.remakeConstraints { (make) in
                make.centerX.equalTo(button)
                make.bottom.equalTo(self).offset(-2)
                make.size.equalTo(CGSize(width: 30, height: 4))
            }
            self.layoutIfNeeded()
        }
    }
    
    @objc
    func musicButtonTouchUpInside(_ button: UIButton) {
        selectedClosure?(.music)
        UIView.animate(withDuration: 0.25) {
            self.sliderView.snp.remakeConstraints { (make) in
                make.centerX.equalTo(button)
                make.bottom.equalTo(self).offset(-2)
                make.size.equalTo(CGSize(width: 30, height: 4))
            }
            self.layoutIfNeeded()
        }
    }
    
    lazy var clipButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_clip"), for: .normal)
        view.setTitle("剪辑", for: .normal)
        view.addTarget(self, action: #selector(clipButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    
    lazy var musicButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_music"), for: .normal)
        view.setTitle("音乐", for: .normal)
        view.addTarget(self, action: #selector(musicButtonTouchUpInside(_:)), for: .touchUpInside)
        return view
    }()
    
    lazy var sliderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xFA3E54)
        view.layer.cornerRadius = 2
        return view
    }()

}
