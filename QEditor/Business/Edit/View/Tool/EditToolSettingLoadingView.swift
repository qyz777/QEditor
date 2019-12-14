//
//  EditToolSettingLoadingView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/12/14.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class EditToolSettingLoadingView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .init(white: 0, alpha: 0.85)
        addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.center.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func show() {
        superview?.bringSubviewToFront(self)
        indicator.startAnimating()
        isHidden = false
    }
    
    public func dismiss() {
        indicator.stopAnimating()
        isHidden = true
    }

    lazy var indicator: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .lineScalePulseOutRapid, color: .white)
        return view
    }()

}
