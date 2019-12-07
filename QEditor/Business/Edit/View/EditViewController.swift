//
//  EditViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/13.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

fileprivate let SETTING_HEIGHT: CGFloat = 200

enum EditSettingType {
    case cut
}

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
    
    public var presenter: (EditViewOutput)!
    
    private var sourceModel: MediaVideoModel?
    
    private var isShowSettings = false
    
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
            presenter.view(self, didLoadMediaVideo: sourceModel!)
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
        view.addSubview(settingContainerView)
        settingContainerView.addSubview(closeSettingButton)
        view.addSubview(containerView)
        addChild(editPlayer)
        containerView.addSubview(editPlayer.view)
        editPlayer.didMove(toParent: self)
        
        addChild(editTool)
        containerView.addSubview(editTool.view)
        editTool.didMove(toParent: self)
        
        settingContainerView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(SETTING_HEIGHT)
        }
        
        closeSettingButton.snp.makeConstraints { (make) in
            make.right.equalTo(-SCREEN_PADDING_X)
            make.top.equalTo(self.settingContainerView).offset(15)
        }
        
        editPlayer.view.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(self.containerView)
            make.height.equalTo(SCREEN_HEIGHT / 2)
        }
        
        editTool.view.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.containerView)
            make.top.equalTo(self.editPlayer.view.snp.bottom)
        }
    }
    
    @objc
    func didClickCloseSettingButton() {
        guard isShowSettings else {
            return
        }
        presenter.viewWillHiddenSettings(self)
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.qe.top = 0
            self.settingContainerView.subviews.forEach {
                $0.alpha = 0
            }
            self.navigationController?.navigationBar.alpha = 1
        }) { (_) in
            self.isShowSettings = false
            self.settingContainerView.subviews.forEach {
                if !$0.isEqual(self.closeSettingButton) {
                    $0.removeFromSuperview()
                }
            }
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
    
    lazy var containerView: UIView = {
        let view = UIView(frame: self.view.bounds)
        return view
    }()
    
    lazy var settingContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var closeSettingButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "tool_bar_setting_close"), for: .normal)
        view.addTarget(self, action: #selector(didClickCloseSettingButton), for: .touchUpInside)
        view.alpha = 0
        return view
    }()

}

extension EditViewController: EditViewInput {
    
    func showSettings(for type: EditSettingType) {
        //todo:根据不同type生成不同view，目前先这么写
        let settingsView = EditToolCutSettingsView()
        settingsView.selecctedClosure = { [unowned self] (type) in
            self.presenter.view(self, didSelectedCutType: type)
        }
        settingContainerView.addSubview(settingsView)
        settingsView.snp.makeConstraints { (make) in
            make.center.equalTo(self.settingContainerView)
            make.left.right.equalTo(self.settingContainerView)
            make.height.equalTo(CUT_SETTINGS_VIEW_HEIGHT)
        }
        settingsView.reloadData()
        settingContainerView.layoutIfNeeded()
        
        presenter.viewWillShowSettings(self)
        UIView.animate(withDuration: 0.25, animations: {
            self.containerView.qe.top = -SETTING_HEIGHT
            self.settingContainerView.subviews.forEach {
                $0.alpha = 1
            }
            self.navigationController?.navigationBar.alpha = 0
        }) { (_) in
            self.isShowSettings = true
        }
    }
    
}
