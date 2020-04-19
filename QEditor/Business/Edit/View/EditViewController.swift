//
//  EditViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/13.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

fileprivate let SETTING_HEIGHT: CGFloat = 110

enum EditSettingType {
    case cut
    case adjust
    case direction
}

public protocol EditViewControllerDelegate: class {
    
    func edit(viewController: EditViewController, stash config: CompositionProjectConfig)
    
}

public class EditViewController: UIViewController {
    
    static func buildView(with urls: [URL]) -> EditViewController {
        let vc = EditViewController(with: urls)
        let p = EditViewPresenter()
        vc.presenter = p
        vc.editPlayer.presenter = p
        vc.editTool.presenter = p
        p.view = vc
        p.playerView = vc.editPlayer
        p.toolView = vc.editTool
        return vc
    }
    
    static func buildView(with config: CompositionProjectConfig) -> EditViewController {
        let vc = EditViewController(with: config)
        let p = EditViewPresenter()
        vc.presenter = p
        vc.editPlayer.presenter = p
        vc.editTool.presenter = p
        p.view = vc
        p.playerView = vc.editPlayer
        p.toolView = vc.editTool
        return vc
    }
    
    public weak var delegate: EditViewControllerDelegate?
    
    var presenter: EditViewOutput!
    
    private var sourceUrls: [URL] = []
    
    private var config: CompositionProjectConfig?
    
    private var isShowSettings = false
    
    init(with urls: [URL]) {
        super.init(nibName: nil, bundle: nil)
        sourceUrls = urls
    }
    
    init(with config: CompositionProjectConfig) {
        super.init(nibName: nil, bundle: nil)
        self.config = config
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        if config != nil {
            view.layoutIfNeeded()
            presenter.importProject(config!)
        } else {
            presenter.view(self, didLoadSource: sourceUrls)
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func initView() {
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        let closeItem = UIBarButtonItem(image: UIImage(named: "album_close"), style: .plain, target: self, action: #selector(didClickCloseButton))
        closeItem.tintColor = .white
        navigationItem.leftBarButtonItem = closeItem
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: exportButton)
        
        view.backgroundColor = .black
        addChild(editPlayer)
        view.addSubview(editPlayer.view)
        editPlayer.didMove(toParent: self)
        
        let toolNav = UINavigationController(rootViewController: editTool)
        toolNav.navigationBar.isHidden = true
        addChild(toolNav)
        view.addSubview(toolNav.view)
        toolNav.didMove(toParent: self)
        
        editPlayer.view.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(self.view)
            make.height.equalTo(SCREEN_HEIGHT / 2)
        }
        
        toolNav.view.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.top.equalTo(self.editPlayer.view.snp.bottom)
        }
        
    }
    
    @objc
    func didClickCloseButton() {
        dismiss(animated: true) {
            self.delegate?.edit(viewController: self, stash: self.presenter.exportProject())
        }
    }
    
    @objc
    func didClickExportButton() {
        presenter.viewShouldExportVideo(self)
    }
    
    lazy var editPlayer: EditPlayerViewController = {
        let p = EditPlayerViewController()
        return p
    }()
    
    lazy var editTool: EditToolViewController = {
        let vc = EditToolViewController()
        return vc
    }()
    
    private lazy var exportButton: UIButton = {
        let view = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        view.setTitle("导出", for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        view.backgroundColor = UIColor.qe.hex(0xFA3E54)
        view.layer.cornerRadius = 4
        view.addTarget(self, action: #selector(didClickExportButton), for: .touchUpInside)
        return view
    }()

}

extension EditViewController: EditViewInput {
    
}
