//
//  MediaViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

let MEDIA_ITEM_SIZE = (SCREEN_WIDTH - SCREEN_PADDING_X * 4) / 3

class MediaViewController: UIViewController {
    
    private var presenter: (AnyObject & MediaPresenterInput)?
    
    public class func buildView() -> UIViewController {
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
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        addChild(videoView)
        containerView.addSubview(videoView.view)
        videoView.didMove(toParent: self)
        
        addChild(imageView)
        containerView.addSubview(imageView.view)
        imageView.didMove(toParent: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoView.view.frame = .init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        imageView.view.frame = .init(x: view.frame.size.width, y: 0, width: view.frame.size.width, height: view.frame.size.height)
    }
    
    lazy var containerView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentSize = .init(width: SCREEN_WIDTH * 2, height: 0)
        view.isPagingEnabled = true
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

extension MediaViewController: MediaViewInput {
    
    
    
}

extension MediaViewController: MediaPresenterOutput {
    
    func presenter(_ presenter: MediaPresenterInput, didAlbumDeniedWithInfo: String) {
        //todo:展示无权限
    }
    
}
