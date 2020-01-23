//
//  HomeViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .custom)
        button.frame = .init(x: 0, y: 0, width: 100, height: 100)
        button.setTitle("相册", for: .normal)
        button.center = view.center
        button.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        button.setTitleColor(.white, for: .normal)
        view.addSubview(button)
    }
    
    @objc
    func clickButton() {
        let vc = MediaViewController.buildView()
        vc.completion = { (_ videos: [MediaVideoModel], _ photos: [MediaImageModel]) in
            if videos.count > 0 {
                self.handleVideos(videos)
            } else if photos.count > 0 {
                
            }
        }
        let nav = NavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    private func handleVideos(_ videos: [MediaVideoModel]) {
        let urls = videos.map { (model) -> URL in
            return model.url!
        }
        let vc = EditViewController.buildView(with: urls)
        let nav = NavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }

}
