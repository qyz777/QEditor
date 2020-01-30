//
//  EditToolViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation
import AudioCollection
import SwifterSwift

fileprivate let CELL_IDENTIFIER = "EditToolImageCell"

/// 容器最小滑动宽度
fileprivate let MIN_SCROLL_WIDTH = SCREEN_WIDTH + SCREEN_WIDTH / 2

/// 容器左边距
fileprivate let CONTAINER_PADDING_LEFT = SCREEN_WIDTH / 2


/// 视图层级枚举
fileprivate enum InsertViewLevel: Int {
    
    //选择框所在的视图层级
    case choose = 99
    
    //分割标记
    case splitFlag = 98
    
}

class EditToolViewController: UIViewController {
    
    public var presenter: (EditToolViewOutput)!
    
    /// 视频时长
    private var duration: Double = 0
    
    /// 加载图片的优化
    private var isEnableOptimize = false
    
    /// 播放器状态
    private var playerStatus: PlayerViewStatus = .error
    
    /// 视频最大宽度，每次新增、删除视频需要重新设置这个属性
    private var videoContentWidth: CGFloat = 0
    
    /// 当前锁定的视频选择框
    private weak var selectedChooseView: EditToolChooseBoxView?
    
    /// 当前锁定的音乐操作视图
    private weak var selectedMusicOperationView: EditAudioWaveformOperationView?
    
    private var videoToolBarModels: [EditToolBarModel] = [
        EditToolBarModel(action: .videoSplit, imageName: "edit_split", text: "分割"),
        EditToolBarModel(action: .videoDelete, imageName: "edit_delete", text: "删除"),
        EditToolBarModel(action: .videoChangeSpeed, imageName: "edit_speed", text: "变速"),
        EditToolBarModel(action: .videoReverse, imageName: "edit_reverse", text: "倒放"),
    ]
    
    private var musicToolBarModels: [EditToolBarModel] = [
        EditToolBarModel(action: .musicReplace, imageName: "edit_replace_music", text: "替换"),
        EditToolBarModel(action: .musicDelete, imageName: "edit_delete", text: "删除"),
        EditToolBarModel(action: .musicEdit, imageName: "edit_edit_music", text: "编辑")
    ]
    
    private var tabSelectedType: EditToolTabSelectedType = .edit
    
    private var musicWaveformViews: [EditAudioWaveformOperationView] = []
    
    //MARK: Override

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        toolBarView.update(videoToolBarModels)
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldHiddenSplitViews(_:)), name: ChooseBoxDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldShowSplitViews(_:)), name: ChooseBoxDidHiddenNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Private
    
    private func initView() {
        view.backgroundColor = .black
        view.addSubview(containerView)
        view.addSubview(verticalTimeLineView)
        view.addSubview(operationContainerView)
        view.addSubview(addButton)
        view.addSubview(loadingView)
        operationContainerView.addSubview(tabView)
        operationContainerView.addSubview(toolBarView)
        containerView.addSubview(contentView)
        contentView.addSubview(thumbView)
        contentView.addSubview(originAudioWaveformView)
        contentView.addSubview(timeScaleView)
        contentView.addSubview(originVideoLabel)
        contentView.addSubview(originAudioLabel)
        contentView.addSubview(musicLabel)
        
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.operationContainerView.snp.top)
        }
        
        operationContainerView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(self.view)
            make.height.equalTo(100)
        }
        
        tabView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.operationContainerView)
            make.height.equalTo(40)
        }
        
        toolBarView.snp.makeConstraints { (make) in
            make.left.right.equalTo(self.operationContainerView)
            make.bottom.equalTo(self.tabView.snp.top)
            make.height.equalTo(60)
        }
        
        verticalTimeLineView.snp.makeConstraints { (make) in
            make.center.equalTo(self.containerView)
            make.width.equalTo(2)
            make.height.equalTo(SCREEN_WIDTH / 3)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.containerView)
            make.height.equalTo(self.containerView)
            make.width.equalTo(self.containerView.contentSize.width)
        }
        
        timeScaleView.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(SCREEN_WIDTH)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.top.equalTo(self.contentView).offset(0)
        }
        
        thumbView.snp.makeConstraints { (make) in
            make.height.equalTo(EDIT_THUMB_CELL_SIZE)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.width.equalTo(SCREEN_WIDTH)
            make.top.equalTo(self.timeScaleView.snp.bottom).offset(15)
        }
        
        originAudioWaveformView.snp.makeConstraints { (make) in
            make.height.equalTo(WAVEFORM_HEIGHT)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.width.equalTo(SCREEN_WIDTH)
            make.top.equalTo(self.thumbView.snp.bottom).offset(5)
        }
        
        originVideoLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView.snp.left).offset(SCREEN_WIDTH / 2 - SCREEN_PADDING_X)
            make.centerY.equalTo(self.thumbView)
        }
        
        originAudioLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.originVideoLabel)
            make.centerY.equalTo(self.originAudioWaveformView)
        }
        
        musicLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.originAudioLabel)
            make.centerY.equalTo(self.originAudioWaveformView.snp.bottom).offset(5 + EDIT_AUDIO_WAVEFORM_SIZE / 2)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-SCREEN_PADDING_X)
            make.centerY.equalTo(self.containerView)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    private func refreshContainerView(_ segments: [EditCompositionVideoSegment]) {
        //1.清除
        clearViewsAndInfos()
        loadingView.dismiss()
        //2.更新容器view的contentSize
        let itemCount = presenter.toolImageThumbViewItemsCount(self)
        //视频最大滑动宽度
        let contentWidth = CGFloat(itemCount) * EDIT_THUMB_CELL_SIZE
        //容器最大滑动宽度
        let containerContentWidth = max(contentWidth + SCREEN_WIDTH, MIN_SCROLL_WIDTH)
        containerView.contentSize = .init(width: containerContentWidth, height: 0)
        contentView.snp.updateConstraints { (make) in
            make.width.equalTo(containerContentWidth)
        }
        view.layoutIfNeeded()
        //3.设置视频最大宽度
        videoContentWidth = contentWidth
        //4.刷新选择框
        var left = SCREEN_WIDTH / 2
        var i = 0
        var resetVideoContentWidth = videoContentWidth
        for segment in segments {
            //处理一下边界case
            var chooseWidth = CGFloat(segment.duration) * EDIT_THUMB_CELL_SIZE
            chooseWidth = resetVideoContentWidth < chooseWidth ? resetVideoContentWidth : chooseWidth
            resetVideoContentWidth -= chooseWidth
            let view = EditToolChooseBoxView(with: chooseWidth)
            view.segment = segment
            selectedChooseView = view
            contentView.insertSubview(view, at: InsertViewLevel.choose.rawValue)
            view.snp.makeConstraints { (make) in
                make.left.equalTo(self.contentView).offset(left)
                make.size.equalTo(CGSize(width: chooseWidth, height: EDIT_THUMB_CELL_SIZE))
                make.centerY.equalTo(self.thumbView.snp.centerY)
            }
            if i + 1 < segments.count {
                //添加分割button
                let view = EditToolSplitButton()
                view.addTarget(self, action: #selector(splitButtonDidClick(_:)), for: .touchUpInside)
                view.index = i
                contentView.insertSubview(view, at: InsertViewLevel.splitFlag.rawValue)
                view.snp.makeConstraints { (make) in
                    make.centerY.equalTo(self.thumbView.snp.centerY)
                    make.centerX.equalTo(self.contentView.snp.left).offset(left + chooseWidth)
                    make.size.equalTo(CGSize(width: 30, height: 30))
                }
            }
            left += chooseWidth
            i += 1
        }
        //5.准备波形图
        presenter.toolView(self, needRefreshWaveformViewWith: .init(width: containerContentWidth, height: WAVEFORM_HEIGHT))
    }
    
    private func clearViewsAndInfos() {
        contentView.subviews.forEach { (view) in
            if view.isKind(of: EditToolChooseBoxView.self) ||
                view.isKind(of: EditToolSplitButton.self) {
                view.removeFromSuperview()
            }
        }
    }
    
    private func showAdjustView(_ info: AdjustProgressViewInfo) -> EditToolAdjustProgressView? {
        guard !view.subviews.contains(where: { (v) -> Bool in
            return v.isKind(of: EditToolAdjustProgressView.self)
        }) else {
            return nil
        }
        let progressView = EditToolAdjustProgressView(info: info)
        view.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalTo(self.view)
            make.height.equalTo(40)
        }
        return progressView
    }
    
    private func thumbViewLoadImagesIfScrollStop() {
        thumbView.loadImages()
    }
    
    private func pushChangeSpeedView() {
        let vc = EditToolChangeSpeedViewController()
        vc.closure = { [unowned self] (progress) in
            guard let forceChooseView = self.selectedChooseView else {
                return
            }
            guard let segment = forceChooseView.segment else {
                return
            }
            self.presenter.toolView(self, didChangeSpeedAt: segment, of: progress)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showMediaSelectedView() {
        let vc = MediaViewController.buildView()
        vc.completion = { [unowned self] (_ videos: [MediaVideoModel], _ photos: [MediaImageModel]) in
            self.presenter.toolView(self, didSelected: videos, images: photos)
        }
        let nav = NavigationController(rootViewController: vc)
        UIViewController.qe.current()?.present(nav, animated: true, completion: nil)
    }
    
    private func showMusicSelectedView() {
        //1.检查是否能够添加
        let cursorX = containerView.contentOffset.x + CONTAINER_PADDING_LEFT
        //只要有1s的间距就可以往里插
        let minPoint = CGPoint(x: cursorX, y: originAudioWaveformView.frame.maxY + 5)
        let maxPoint = CGPoint(x: cursorX + EDIT_THUMB_CELL_SIZE, y: originAudioWaveformView.frame.maxY + 5)
        //遍历数组中的view是否包含这个point
        for view in musicWaveformViews {
            if view.frame.contains(maxPoint) || view.frame.contains(minPoint) {
                MessageBanner.warning(content: "此位置无法添加音频")
                return
            }
        }
        //2.唤起媒体资料库
        let vc = AudioCollectionViewController()
        vc.selectedClosure = { [unowned self] (model) in
            guard let url = model.assetURL else { return }
            let asset = AVURLAsset(url: url)
            self.presenter.toolView(self, addMusicFrom: asset, title: model.title)
        }
        let nav = NavigationController(rootViewController: vc)
        UIViewController.qe.current()?.present(nav, animated: true, completion: nil)
    }
    
    private func musicTrackBecomeOperation() {
        guard musicWaveformViews.count > 0 else {
            return
        }
        musicWaveformViews.first!.showOperationView()
        selectedMusicOperationView = musicWaveformViews.first
    }
    
    private func musicTrackResignOperation() {
        musicWaveformViews.forEach {
            $0.hiddenOperationView()
        }
        selectedMusicOperationView = nil
    }
    
    private func replaceSelectedMusic() {
        guard let segment = selectedMusicOperationView?.segment else {
            MessageBanner.warning(content: "当前没有选中音乐")
            return
        }
        let vc = AudioCollectionViewController()
        vc.selectedClosure = { [unowned self] (model) in
            guard let url = model.assetURL else { return }
            let newSegment = EditCompositionAudioSegment(url: url)
            self.presenter.toolView(self, replaceMusic: segment, for: newSegment)
        }
        let nav = NavigationController(rootViewController: vc)
        UIViewController.qe.current()?.present(nav, animated: true, completion: nil)
    }
    
    private func removeSelectedMusic() {
        guard let waveformView = selectedMusicOperationView else {
            MessageBanner.warning(content: "当前没有选中音乐")
            return
        }
        guard let segment = waveformView.segment else { return }
        let actionSheet = UIAlertController(title: "提示", message: "删除当前选定的音乐", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            self.presenter.toolView(self, removeMusic: segment)
            self.musicWaveformViews.removeAll {
                if $0.segment == nil {
                    $0.removeFromSuperview()
                    return true
                }
                return $0.segment! == segment
            }
            waveformView.removeFromSuperview()
            MessageBanner.success(content: "删除成功")
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(okAction)
        actionSheet.addAction(cancelAction)
        UIViewController.qe.current()?.present(actionSheet, animated: true, completion: nil)
    }
    
    private func pushToEditMusic() {
        guard let segment = selectedMusicOperationView?.segment else {
            MessageBanner.warning(content: "当前没有选中音乐片段")
            return
        }
        let vc = EditToolAudioDetailSettingsViewController()
        vc.volumeClosure = { [unowned self] (value) in
            self.presenter.toolView(self, change: value, of: segment)
        }
        vc.fadeInClosure = { [unowned self] (on) in
            self.presenter.toolView(self, changeFadeIn: on, of: segment)
        }
        vc.fadeOutClosure = { [unowned self] (on) in
            self.presenter.toolView(self, changeFadeOut: on, of: segment)
        }
        vc.chooseClosure = { [unowned self] (start) in
            self.presenter.toolView(self, updateMusic: segment, atNew: start)
        }
        vc.update(segment)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Action
    
    @objc
    func didClickAddButton() {
        switch tabSelectedType {
        case .edit:
            showMediaSelectedView()
        case .music:
            showMusicSelectedView()
        }
    }
    
    @objc
    func splitButtonDidClick(_ button: EditToolSplitButton) {
        let vc = EditToolTransformViewController()
        vc.currentTransition = presenter.toolView(self, transitionAt: button.index)
        vc.selectedClosure = { [unowned self] (model) in
            self.presenter.toolView(self, didSelectedSplit: button.index, withTransition: model)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Notification
    @objc
    func shouldHiddenSplitViews(_ notification: Notification) {
        contentView.subviews.forEach {
            if $0.isKind(of: EditToolSplitButton.self) {
                $0.isHidden = true
            }
        }
        let obj = notification.object as? EditToolChooseBoxView
        selectedChooseView = obj
        contentView.subviews.forEach {
            guard let view = $0 as? EditToolChooseBoxView else {
                return
            }
            if !view.isEqual(obj) {
                view.hidden()
            }
        }
    }
    
    @objc
    func shouldShowSplitViews(_ notification: Notification) {
        selectedChooseView = nil
        contentView.subviews.forEach {
            if $0.isKind(of: EditToolSplitButton.self) {
                $0.isHidden = false
            }
        }
        contentView.subviews.forEach {
            guard let view = $0 as? EditToolChooseBoxView else {
                return
            }
            view.hidden()
        }
    }
    
    //MARK: Getter
    
    private lazy var containerView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.contentSize = .init(width: MIN_SCROLL_WIDTH, height: 0)
        view.delegate = self
        return view
    }()
    
    private lazy var contentView: EditToolContentView = {
        let view = EditToolContentView()
        return view
    }()
    
    private lazy var verticalTimeLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        return view
    }()
    
    private lazy var thumbView: EditToolImageThumbView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = EditToolImageThumbView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EDIT_THUMB_CELL_SIZE), collectionViewLayout: layout)
        view.isScrollEnabled = false
        view.layer.cornerRadius = 4
        view.itemCountClosure = { [unowned self] in
            return self.presenter.toolImageThumbViewItemsCount(self)
        }
        view.itemModelClosure = { [unowned self] (item: Int) -> EditToolImageCellModel in
            return self.presenter.toolView(self, thumbModelAt: item)
        }
        return view
    }()
    
    private lazy var originAudioWaveformView: EditToolAudioWaveFormView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = .init(width: EDIT_THUMB_CELL_SIZE, height: WAVEFORM_HEIGHT)
        let view = EditToolAudioWaveFormView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: WAVEFORM_HEIGHT), collectionViewLayout: layout)
        view.layer.cornerRadius = 4
        view.isScrollEnabled = false
        return view
    }()
    
    private lazy var timeScaleView: EditToolTimeScaleView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = EditToolTimeScaleView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 25), collectionViewLayout: layout)
        view.isScrollEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.itemCountClosure = { [unowned self] in
            return self.presenter.toolImageThumbViewItemsCount(self)
        }
        view.itemContentClosure = { [unowned self] (item: Int) -> String in
            self.presenter.toolView(self, contentAt: item)
        }
        return view
    }()
    
    private lazy var toolBarView: EditToolBar = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 30
        let view = EditToolBar(frame: .zero, collectionViewLayout: layout)
        view.contentInset = .init(top: 0, left: 30, bottom: 0, right: 30)
        view.selectedClosure = { [unowned self] (model) in
            switch model.action {
            case .videoSplit:
                self.presenter.toolViewShouldSplitVideo(self)
            case .videoDelete:
                self.deletePart()
            case .videoChangeSpeed:
                self.pushChangeSpeedView()
            case .videoReverse:
                self.loadingView.show()
                MessageBanner.show(title: "任务", subTitle: "开始执行反转视频任务", style: .info)
                self.presenter.toolViewShouldReverseVideo(self)
            case .musicReplace:
                self.replaceSelectedMusic()
            case .musicEdit:
                self.pushToEditMusic()
            case .musicDelete:
                self.removeSelectedMusic()
            }
        }
        return view
    }()
    
    private lazy var addButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 4
        view.setImage(UIImage(named: "tool_bar_plus"), for: .normal)
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        view.addTarget(self, action: #selector(didClickAddButton), for: .touchUpInside)
        return view
    }()
    
    private lazy var operationContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var tabView: EditToolTabView = {
        let view = EditToolTabView(frame: .zero)
        view.selectedClosure = { [unowned self] (type) in
            self.tabSelectedType = type
            switch type {
            case .edit:
                self.musicTrackResignOperation()
                self.toolBarView.update(self.videoToolBarModels)
            case .music:
                self.musicTrackBecomeOperation()
                self.toolBarView.update(self.musicToolBarModels)
            }
        }
        return view
    }()
    
    private lazy var loadingView: EditToolSettingLoadingView = {
        let view = EditToolSettingLoadingView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    private lazy var originVideoLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "视频轨道"
        return view
    }()
    
    private lazy var originAudioLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "原声轨道"
        return view
    }()
    
    private lazy var musicLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "音乐轨道"
        return view
    }()

}

//MARK: EditToolViewInput
extension EditToolViewController: EditToolViewInput {
    
    func refreshWaveFormView(with asset: AVAsset) {
        originAudioWaveformView.update(asset)
    }
    
    func currentCursorTime() -> Double {
        let offsetX = containerView.contentOffset.x
        let totalWidth = containerView.contentSize.width
        let percent = min(Float(offsetX / (totalWidth - SCREEN_WIDTH)), 1)
        return duration * Double(percent)
    }
    
    func deletePart() {
        //[剪辑][删除]
        //1.校验是否有选定视频
        guard presenter.toolViewCanDeleteAtComposition(self) else {
            MessageBanner.show(title: "提示", subTitle: "当前只有一段视频，无法删除", style: .warning)
            return
        }
        //2.删除选定视频
        let deleteSegment = selectedChooseView!.segment
        guard deleteSegment != nil else {
            return
        }
        //3.抛给presenter删除
        presenter.toolView(self, delete: deleteSegment!)
    }
    
    func showChangeBrightnessView(_ info: AdjustProgressViewInfo) {
        if let progressView = showAdjustView(info) {
            progressView.closure = { [unowned self] (progress) in
                guard let forceChooseView = self.selectedChooseView else {
                    return
                }
                guard let segment = forceChooseView.segment else {
                    return
                }
                self.presenter.toolView(self, didChangeBrightnessFrom: segment.rangeAtComposition.start.seconds, to: segment.rangeAtComposition.end.seconds, of: progress)
            }
        }
    }
    
    func showChangeSaturationView(_ info: AdjustProgressViewInfo) {
        if let progressView = showAdjustView(info) {
            progressView.closure = { [unowned self] (progress) in
                guard let forceChooseView = self.selectedChooseView else {
                    return
                }
                guard let segment = forceChooseView.segment else {
                    return
                }
                self.presenter.toolView(self, didChangeSaturationFrom: segment.rangeAtComposition.start.seconds, to: segment.rangeAtComposition.end.seconds, of: progress)
            }
        }
    }
    
    func showChangeContrastView(_ info: AdjustProgressViewInfo) {
        if let progressView = showAdjustView(info) {
            progressView.closure = { [unowned self] (progress) in
                guard let forceChooseView = self.selectedChooseView else {
                    return
                }
                guard let segment = forceChooseView.segment else {
                    return
                }
                self.presenter.toolView(self, didChangeContrastFrom: segment.rangeAtComposition.start.seconds, to: segment.rangeAtComposition.end.seconds, of: progress)
            }
        }
    }
    
    func showChangeGaussianBlurView(_ info: AdjustProgressViewInfo) {
        if let progressView = showAdjustView(info) {
            progressView.closure = { [unowned self] (progress) in
                guard let forceChooseView = self.selectedChooseView else {
                    return
                }
                guard let segment = forceChooseView.segment else {
                    return
                }
                self.presenter.toolView(self, didChangeGaussianBlurFrom: segment.rangeAtComposition.start.seconds, to: segment.rangeAtComposition.end.seconds, of: progress)
            }
        }
    }
    
    func selectedVideoSegment() -> EditCompositionVideoSegment? {
        return selectedChooseView?.segment
    }
    
    func reloadView(_ segments: [EditCompositionVideoSegment]) {
        refreshContainerView(segments)
        thumbView.reloadData()
        timeScaleView.reloadData()
    }
    
    func refreshView(_ segments: [EditCompositionVideoSegment]) {
        refreshContainerView(segments)
    }
    
    func loadVideoModel(_ model: EditVideoModel) {
        
    }
    
    func loadAsset(_ asset: AVAsset) {
        thumbView.asset = asset
    }
    
    func updatePlayTime(_ time: Double) {
        guard duration > 0 else {
            return
        }
        let percent = CGFloat(time) / CGFloat(duration)
        guard percent <= 1 else {
            return
        }
        let totalWidth = videoContentWidth
        let offsetX = totalWidth * percent
        containerView.contentOffset = .init(x: offsetX, y: 0)
    }
    
    func updateDuration(_ duration: Double) {
        self.duration = duration
        isEnableOptimize = duration > 60
    }
    
    func updatePlayViewStatus(_ status: PlayerViewStatus) {
        playerStatus = status
    }
    
    func addMusicAudioWaveformView(for segment: EditCompositionAudioSegment) {
        //唤起媒体资料库的时候检查过添加合法性了，这里就不再检查了
        let cursorX = containerView.contentOffset.x + CONTAINER_PADDING_LEFT
        var offsetRight = videoContentWidth
        var offsetLeft = videoContentWidth
        var nextWaveformView: EditAudioWaveformOperationView?
        var preWaveformView: EditAudioWaveformOperationView?
        musicWaveformViews.forEach {
            if $0.x > cursorX {
                let distance = $0.x - cursorX
                if distance < offsetRight {
                    nextWaveformView = $0
                    offsetRight = distance
                }
            } else {
                let distance = cursorX - $0.frame.maxX
                if distance < offsetLeft {
                    preWaveformView = $0
                    offsetLeft = distance
                }
            }
        }
        let width: CGFloat
        let cursorOffset = containerView.contentOffset.x + SCREEN_WIDTH / 2
        if nextWaveformView != nil {
            width = nextWaveformView!.x - cursorOffset
        } else {
            width = videoContentWidth - cursorOffset + CONTAINER_PADDING_LEFT
        }
        let waveformView = EditAudioWaveformOperationView(frame: CGRect(x: 0, y: 0, width: width, height: EDIT_AUDIO_WAVEFORM_SIZE))
        waveformView.segment = segment
        waveformView.selectedClosure = { [unowned self, waveformView] (isSelected) in
            if isSelected {
                self.selectedMusicOperationView = waveformView
            } else {
                self.selectedMusicOperationView = nil
            }
            for view in self.musicWaveformViews {
                if !view.isEqual(waveformView) {
                    view.hiddenOperationView()
                }
            }
        }
        var currentX = waveformView.x
        var currentWidth = waveformView.width
        waveformView.handleLeftPanClosure = { [unowned self, waveformView] (pan) in
            switch pan.state {
            case .began:
                currentX = waveformView.x
                currentWidth = waveformView.width
            case .changed:
                //1.检查条件
                let offsetX = pan.translation(in: waveformView).x
                let newLeft: CGFloat
                if offsetX < 0 {
                    //向左
                    newLeft = max(preWaveformView != nil ? preWaveformView!.frame.maxX : CONTAINER_PADDING_LEFT, currentX + offsetX)
                } else {
                    //向右
                    newLeft = min(waveformView.frame.maxX - EDIT_AUDIO_WAVEFORM_SIZE, currentX + offsetX)
                }
                var newWidth = currentWidth + currentX - newLeft
                newWidth = min(newWidth, CGFloat(segment.assetDuration) * EDIT_AUDIO_WAVEFORM_SIZE)
                //2.开始移动
                waveformView.snp.updateConstraints { (make) in
                    make.left.equalTo(self.contentView).offset(newLeft)
                    make.width.equalTo(newWidth)
                }
                waveformView.layoutIfNeeded()
            case .ended:
                let start = Double(waveformView.x - CONTAINER_PADDING_LEFT) / Double(self.videoContentWidth) * self.duration
                let end = Double(waveformView.frame.maxX - CONTAINER_PADDING_LEFT) / Double(self.videoContentWidth) * self.duration
                self.presenter.toolView(self, updateMusic: segment, timeRange: CMTimeRange(start: start, end: end))
            default:
                break
            }
        }
        waveformView.handleRightPanClosure = { [unowned self, waveformView] (pan) in
            switch pan.state {
            case .began:
                currentX = waveformView.frame.maxX
                currentWidth = waveformView.width
            case .changed:
                //1.检查条件
                let offsetX = pan.translation(in: waveformView).x
                let newRight: CGFloat
                if offsetX < 0 {
                    //向左
                    newRight = max(waveformView.x + EDIT_AUDIO_WAVEFORM_SIZE, currentX + offsetX)
                } else {
                    //向右
                    newRight = min(nextWaveformView != nil ? nextWaveformView!.x : self.containerView.contentSize.width - CONTAINER_PADDING_LEFT, currentX + offsetX)
                }
                var newWidth = newRight - waveformView.x
                newWidth = min(newWidth, CGFloat(segment.assetDuration) * EDIT_AUDIO_WAVEFORM_SIZE)
                //2.开始移动
                waveformView.snp.updateConstraints { (make) in
                    make.width.equalTo(newWidth)
                }
                waveformView.layoutIfNeeded()
            case .ended:
                let start = Double(waveformView.x - CONTAINER_PADDING_LEFT) / Double(self.videoContentWidth) * self.duration
                let end = Double(waveformView.frame.maxX - CONTAINER_PADDING_LEFT) / Double(self.videoContentWidth) * self.duration
                self.presenter.toolView(self, updateMusic: segment, timeRange: CMTimeRange(start: start, end: end))
            default:
                break
            }
        }
        contentView.addSubview(waveformView)
        waveformView.snp.makeConstraints { (make) in
            make.top.equalTo(originAudioWaveformView.snp.bottom).offset(5)
            make.left.equalTo(self.contentView).offset(cursorOffset)
            make.width.equalTo(width)
            make.height.equalTo(EDIT_AUDIO_WAVEFORM_SIZE)
        }
        musicWaveformViews.append(waveformView)
        MessageBanner.show(title: "成功", subTitle: "添加音乐成功", style: .success)
    }
    
    func refreshMusicWaveformView(with segment: EditCompositionAudioSegment) {
        guard let waveformView = selectedMusicOperationView else { return }
        guard let asset = waveformView.segment?.asset else { return }
        if asset.duration < segment.rangeAtComposition.duration {
            //这个时候说明音乐view要变短，range则会取最大的range
            //算一个百分比让他变短
            let percent = asset.duration.seconds / segment.rangeAtComposition.duration.seconds
            waveformView.snp.makeConstraints { (make) in
                make.width.equalTo(waveformView.width * CGFloat(percent))
            }
            waveformView.layoutIfNeeded()
        }
        waveformView.segment = segment
        MessageBanner.success(content: "替换成功")
    }
    
}

//MARK: UIScrollViewDelegate
extension EditToolViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let totalWidth = scrollView.contentSize.width
        
        if totalWidth - SCREEN_WIDTH > 0 && playerStatus != .playing {
            let percent = min(Float(offsetX / (totalWidth - SCREEN_WIDTH)), 1)
            presenter.toolView(self, isDraggingWith: percent)
        }
        
        if offsetX < SCREEN_WIDTH / 2 {
            //在左侧滚动
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            originAudioWaveformView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            thumbView.contentOffset = .zero
            timeScaleView.contentOffset = .zero
            originAudioWaveformView.contentOffset = .zero
        } else if offsetX >= SCREEN_WIDTH / 2 && offsetX < totalWidth - SCREEN_WIDTH * 1.5 {
            //在中间滚动
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            originAudioWaveformView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            let newOffsetX = offsetX - SCREEN_WIDTH / 2
            thumbView.contentOffset = .init(x: newOffsetX, y: 0)
            timeScaleView.contentOffset = .init(x: newOffsetX, y: 0)
            originAudioWaveformView.contentOffset = .init(x: newOffsetX, y: 0)
        } else {
            //在右侧滚动
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            originAudioWaveformView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            thumbView.contentOffset = .init(x: thumbView.contentSize.width - SCREEN_WIDTH, y: 0)
            timeScaleView.contentOffset = .init(x: timeScaleView.contentSize.width - SCREEN_WIDTH, y: 0)
            originAudioWaveformView.contentOffset = .init(x: originAudioWaveformView.contentSize.width - SCREEN_WIDTH, y: 0)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let totalWidth = scrollView.contentSize.width
        if totalWidth - SCREEN_WIDTH > 0 {
            let percent = Float(offsetX / (totalWidth - SCREEN_WIDTH))
            presenter.toolView(self, isDraggingWith: percent)
        }
        
        presenter.toolViewDidEndDecelerating(self)
        
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if isEnableOptimize {
            if scrollToScrollStop {
                thumbViewLoadImagesIfScrollStop()
                thumbView.isNeedLoadImageAtDisplay = true
            } else {
                thumbView.isNeedLoadImageAtDisplay = false
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        presenter.toolViewWillBeginDragging(self)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if isEnableOptimize {
            if !decelerate {
                let dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
                if dragToDragStop {
                    thumbViewLoadImagesIfScrollStop()
                    thumbView.isNeedLoadImageAtDisplay = true
                } else {
                    thumbView.isNeedLoadImageAtDisplay = false
                }
            } else {
                thumbView.isNeedLoadImageAtDisplay = false
            }
        }
    }
    
}

fileprivate class EditToolContentView: UIView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        //优先响应分割button
        for view in subviews {
            if let button: EditToolSplitButton = view as? EditToolSplitButton {
                if button.frame.contains(point) {
                    return button
                }
            }
        }
        return super.hitTest(point, with: event)
    }
    
}
