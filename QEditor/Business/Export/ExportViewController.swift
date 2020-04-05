//
//  ExportViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/5.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import Photos

class ExportViewController: UIViewController {
    
    var exporter: CompositionExporter? {
        willSet {
            guard let exporter = newValue else { return }
            exporter.progressClosure = { [unowned self] (value) in
                QELog(value)
                self.progressView.setProgress(value, animated: true)
            }
            exporter.completion = { (url) in
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                }) { (success, error) in
                    DispatchQueue.main.async {
                        if success {
                            MessageBanner.success(content: "成功保存至相册")
                        } else {
                            MessageBanner.error(content: "保存到相册失败")
                            QELog(error)
                        }
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "导出"
        view.backgroundColor = .black

        let closeItem = UIBarButtonItem(image: UIImage(named: "album_close"), style: .plain, target: self, action: #selector(didClickCloseButton))
        closeItem.tintColor = .white
        navigationItem.leftBarButtonItem = closeItem
        
        
        view.addSubview(infoLabel)
        view.addSubview(progressView)
        
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(SCREEN_WIDTH / 3 * 2)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if exporter?.prepare() ?? false {
            exporter?.start()
        }
    }
    
    @objc
    func didClickCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    private lazy var infoLabel: UILabel = {
        let view = UILabel()
        view.text = "导出中，请不要退出页面或APP"
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        return view
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.backgroundColor = .gray
        view.progressTintColor = UIColor.qe.hex(0xFA3E54)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()

}
