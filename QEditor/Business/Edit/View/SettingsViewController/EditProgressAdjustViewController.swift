//
//  EditProgressAdjustViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/4.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class EditProgressAdjustViewController: EditToolBaseSettingsViewController {
    
    public var operationCancelClosure: (() -> Void)?
    
    public var operationChangeClosure: ((_ progress: Float) -> Void)? {
        willSet {
            progressView?.progressChangeClosure = newValue
        }
    }
    
    public var info: AdjustProgressViewInfo? {
        willSet {
            guard let info = newValue else { return }
            progressView?.removeFromSuperview()
            progressView = EditToolAdjustProgressView(info: info)
            view.addSubview(progressView!)
            progressView?.snp.makeConstraints({ (make) in
                make.top.equalTo(self.topBar.snp.bottom)
                make.left.right.bottom.equalToSuperview()
            })
        }
    }
    
    private var progressView: EditToolAdjustProgressView?
    
    private var isFinish = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isFinish {
            operationCancelClosure?()
        }
    }
    
    override func backButtonTouchUpIndside() {
        operationCancelClosure?()
        super.backButtonTouchUpIndside()
    }
    
    override func operationDidFinish() {
        isFinish = true
        navigationController?.popViewController(animated: true)
    }

}
