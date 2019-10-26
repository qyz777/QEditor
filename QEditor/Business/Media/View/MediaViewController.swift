//
//  MediaViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

typealias MediaViewClosure = (_ videos: [MediaVideoModel], _ photos: [MediaImageModel]) -> Void

let MEDIA_ITEM_SIZE = (SCREEN_WIDTH - SCREEN_PADDING_X * 4) / 3

class MediaViewController: UIViewController {
    
    public var completion: MediaViewClosure?
    
    private var presenter: (AnyObject & MediaPresenterInput & MediaViewOutput)!
    
    public class func buildView() -> MediaViewController {
        let presenter = MediaPresenter()
        let vc = MediaViewController()
        vc.presenter = presenter
        vc.videoView.presenter = presenter
        vc.imageView.presenter = presenter
        presenter.view = vc
        presenter.videoView = vc.videoView
        presenter.imageView = vc.imageView
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        presenter?.requestAuthorizationIfNeed()
    }
    
    private func initView() {
        view.backgroundColor = .black
        navigationItem.title = "相册"
        
        view.addSubview(videoLabel)
        view.addSubview(photoLabel)
        view.addSubview(containerView)
        view.addSubview(addButton)
        
        videoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(64 + 11)
            make.right.equalTo(self.view.snp.centerX).offset(-20)
        }
        
        photoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(64 + 11)
            make.left.equalTo(self.view.snp.centerX).offset(20)
        }
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.videoLabel.snp.bottom).offset(11)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.addButton.snp.top).offset(-11)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).offset(-11)
            make.left.equalTo(self.view).offset(SCREEN_PADDING_X)
            make.right.equalTo(self.view).offset(-SCREEN_PADDING_X)
            make.height.equalTo(44)
        }
        
        addChild(videoView)
        containerView.addSubview(videoView.view)
        videoView.didMove(toParent: self)
        
        addChild(imageView)
        containerView.addSubview(imageView.view)
        imageView.didMove(toParent: self)
        
        let closeItem = UIBarButtonItem(image: UIImage(named: "album_close"), style: .plain, target: self, action: #selector(didClickCloseButton))
        closeItem.tintColor = .white
        navigationItem.leftBarButtonItem = closeItem
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoView.view.frame = .init(x: 0, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
        imageView.view.frame = .init(x: view.frame.size.width, y: 0, width: containerView.frame.size.width, height: containerView.frame.size.height)
    }
    
    @objc
    func didClickCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func didClickAddButton() {
        let tuple = presenter.mediaViewShouldCompletion(self)
        dismiss(animated: true) {
            self.completion?(tuple.0, tuple.1)
        }
    }
    
    lazy var containerView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentSize = .init(width: SCREEN_WIDTH * 2, height: 0)
        view.isPagingEnabled = true
        view.bounces = false
        view.delegate = self
        return view
    }()
    
    lazy var addButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setTitle("添加到项目", for: .normal)
        view.addTarget(self, action: #selector(didClickAddButton), for: .touchUpInside)
        view.backgroundColor = UIColor.qe.hex(0xFA3E54)
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var photoLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.textColor = .lightGray
        view.text = "照片"
        return view
    }()
    
    lazy var videoLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 15)
        view.textColor = .white
        view.text = "视频"
        return view
    }()
    
    lazy var videoView: MediaVideoViewController = {
        let vc = MediaVideoViewController()
        return vc
    }()
    
    lazy var imageView: MediaImageViewController = {
        let vc = MediaImageViewController()
        return vc
    }()

}

extension MediaViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < SCREEN_WIDTH {
            photoLabel.textColor = .lightGray
            videoLabel.textColor = .white
        } else {
            photoLabel.textColor = .white
            videoLabel.textColor = .lightGray
        }
    }
    
}

extension MediaViewController: MediaViewInput {
    
    
    
}

extension MediaViewController: MediaPresenterOutput {
    
    func presenter(_ presenter: MediaPresenterInput, didSelectWith count: Int) {
        if count == 0 {
            addButton.setTitle("添加到项目", for: .normal)
        } else {
            addButton.setTitle("添加到项(\(count))", for: .normal)
        }
    }
    
}
