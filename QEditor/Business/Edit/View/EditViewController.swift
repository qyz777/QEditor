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

class EditViewController: UIViewController {
    
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
    
    public var presenter: EditViewOutput!
    
    private var sourceUrls: [URL] = []
    
    private var isShowSettings = false
    
    init(with urls: [URL]) {
        super.init(nibName: nil, bundle: nil)
        sourceUrls = urls
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        presenter.view(self, didLoadSource: sourceUrls)
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
        settingContainerView.addSubview(settingLoadingView)
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
            make.top.equalTo(self.settingContainerView)
        }
        
        editPlayer.view.snp.makeConstraints { (make) in
            make.top.right.left.equalTo(self.containerView)
            make.height.equalTo(SCREEN_HEIGHT / 2)
        }
        
        editTool.view.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.containerView)
            make.top.equalTo(self.editPlayer.view.snp.bottom)
        }
        
        settingLoadingView.snp.makeConstraints { (make) in
            make.top.equalTo(self.closeSettingButton.snp.bottom)
            make.left.right.bottom.equalTo(self.settingContainerView)
        }
        
    }
    
    @objc
    func didClickCloseSettingButton() {
        hiddenSettings()
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
    
    lazy var settingLoadingView: EditToolSettingLoadingView = {
        let view = EditToolSettingLoadingView(frame: .zero)
        view.isHidden = true
        return view
    }()

}

extension EditViewController: EditViewInput {
    
    func showSettings(for type: EditSettingType) {
        var settingsView = settingsViewFactoryFor(type: type)
        settingsView.selectedClosure = { [unowned self] (action) in
            self.presenter.view(self, didSelectedSetting: action)
        }
        settingContainerView.insertSubview(settingsView, at: 0)
        settingsView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.settingContainerView)
            make.height.equalTo(EDIT_TOOL_SETTINGS_VIEW_HEIGHT)
        }
        settingsView.reload()
        settingContainerView.layoutIfNeeded()
        
        //再打开还在任务执行中，展示loading
        if presenter.viewIsLoading(self) {
            taskWillBegin()
        }
        
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
    
    func hiddenSettings() {
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
                if $0 is EditToolSettingsViewProtocol {
                    $0.removeFromSuperview()
                }
            }
        }
    }
    
    func taskWillBegin() {
        settingLoadingView.show()
    }
    
    func taskDidComplete() {
        settingLoadingView.dismiss()
    }
    
}
