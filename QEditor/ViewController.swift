//
//  ViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

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
        let nav = NavigationController(rootViewController: MediaViewController.buildView())
        present(nav, animated: true, completion: nil)
    }


}

