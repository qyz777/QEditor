//
//  EditViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/13.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

class EditViewController: UIViewController {
    
    static func buildView(with model: MediaVideoModel) -> EditViewController {
        let vc = EditViewController(with: model)
        let p = EditViewPresenter()
        vc.presenter = p
        vc.editPlayer.presenter = p
        vc.editTool.presenter = p
        p.view = vc
        p.playerView = vc.editPlayer
        p.toolView = vc.editTool
        return vc
    }
    
    public var presenter: (EditViewPresenterInput & EditViewOutput)!
    
    private var sourceModel: MediaVideoModel?
    
    init(with videoModel: MediaVideoModel) {
        super.init(nibName: nil, bundle: nil)
        sourceModel = videoModel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        if sourceModel != nil {
            presenter.prepare(forVideo: sourceModel!)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func initView() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let closeItem = UIBarButtonItem(image: UIImage(named: "album_close"), style: .plain, target: self, action: #selector(didClickCloseButton))
        closeItem.tintColor = .white
        navigationItem.leftBarButtonItem = closeItem
        
        view.backgroundColor = .black
        
        addChild(editPlayer)
        view.addSubview(editPlayer.view)
        editPlayer.didMove(toParent: self)
        
        addChild(editTool)
        view.addSubview(editTool.view)
        editTool.didMove(toParent: self)
        
        editPlayer.view.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(self.view)
            make.height.equalTo(SCREEN_HEIGHT / 2)
        }
        
        editTool.view.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.editPlayer.view.snp.bottom)
        }
    }
    
    @objc
    func didClickCloseButton() {
        dismiss(animated: true, completion: nil)
    }
    
    lazy var editPlayer: EditPlayerViewController = {
        let p = EditPlayerViewController()
        return p
    }()
    
    lazy var editTool: EditToolViewController = {
        let vc = EditToolViewController()
        return vc
    }()

}

extension EditViewController: EditViewInput {
    
    
    
}
