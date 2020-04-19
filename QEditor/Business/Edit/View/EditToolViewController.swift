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
let MIN_SCROLL_WIDTH = SCREEN_WIDTH + SCREEN_WIDTH / 2

/// 容器左边距
let CONTAINER_PADDING_LEFT = SCREEN_WIDTH / 2


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
    private var playerStatus: CompositionPlayerStatus = .error
    
    private var videoContentWidth: CGFloat {
        return presenter.containerContentWidth
    }
    
    /// 当前锁定的视频选择框
    private weak var selectedChooseView: EditToolChooseBoxView?
    
    private var selectedMusicCell: EditOperationAudioCell? {
        return musicContainer.selectedCell as? EditOperationAudioCell
    }
    
    private var selectedRecordCell: EditOperationAudioCell? {
        return recordContainer.selectedCell as? EditOperationAudioCell
    }
    
    private var selectedCaptionCell: EditOperationCaptionCell? {
        return captionContainerView.selectedCell as? EditOperationCaptionCell
    }
    
    private var videoToolBarModels: [EditToolBarModel] = [
        EditToolBarModel(action: .splitVideo, imageName: "edit_split", text: "分割"),
        EditToolBarModel(action: .deleteVideo, imageName: "edit_delete", text: "删除"),
        EditToolBarModel(action: .videoChangeSpeed, imageName: "edit_speed", text: "变速"),
        EditToolBarModel(action: .videoReverse, imageName: "edit_reverse", text: "倒放"),
    ]
    
    private var adjustToolBarModels: [EditToolBarModel] = [
        EditToolBarModel(action: .filters, imageName: "edit_effect_filters", text: "滤镜"),
        EditToolBarModel(action: .brightnessAdjust, imageName: "edit_brightness_adjust", text: "亮度"),
        EditToolBarModel(action: .exposureAdjust, imageName: "edit_exposure_adjust", text: "曝光"),
        EditToolBarModel(action: .contrastAdjust, imageName: "edit_contrast_adjust", text: "对比度"),
        EditToolBarModel(action: .contrastAdjust, imageName: "edit_saturation_adjust", text: "饱和度")
    ]
    
    private var musicToolBarModels: [EditToolBarModel] = [
        EditToolBarModel(action: .replaceMusic, imageName: "edit_replace_music", text: "替换"),
        EditToolBarModel(action: .deleteMusic, imageName: "edit_delete", text: "删除"),
        EditToolBarModel(action: .editMusic, imageName: "edit_edit_music", text: "编辑")
    ]
    
    private var recordToolBarModels: [EditToolBarModel] = [
        EditToolBarModel(action: .deleteRecord, imageName: "edit_delete", text: "删除"),
        EditToolBarModel(action: .editRecord, imageName: "edit_edit_music", text: "编辑")
    ]
    
    private var textToolBarModels: [EditToolBarModel] = [
        EditToolBarModel(action: .deleteCaption, imageName: "edit_delete", text: "删除"),
        EditToolBarModel(action: .editCaptionStyle, imageName: "edit_style", text: "样式"),
        EditToolBarModel(action: .editCaption, imageName: "edit_edit_music", text: "编辑")
    ]
    
    private var tabSelectedType: EditToolTabSelectedType = .edit
    
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
        contentView.addSubview(captionContainerView)
        contentView.addSubview(originVideoLabel)
        contentView.addSubview(originAudioLabel)
        contentView.addSubview(musicLabel)
        contentView.addSubview(recordAudioLabel)
        contentView.addSubview(captionLabel)
        contentView.addSubview(musicContainer)
        contentView.addSubview(recordContainer)
        contentView.addSubview(muteButton)
        
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
        
        musicContainer.snp.makeConstraints { (make) in
            make.height.equalTo(EDIT_OPERATION_VIEW_HEIGHT)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.right.equalTo(self.contentView).offset(-CONTAINER_PADDING_LEFT)
            make.top.equalTo(self.originAudioWaveformView.snp.bottom).offset(5)
        }
        
        recordContainer.snp.makeConstraints { (make) in
            make.height.equalTo(EDIT_OPERATION_VIEW_HEIGHT)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.right.equalTo(self.contentView).offset(-CONTAINER_PADDING_LEFT)
            make.top.equalTo(self.musicContainer.snp.bottom).offset(5)
        }
        
        captionContainerView.snp.makeConstraints { (make) in
            make.height.equalTo(EDIT_OPERATION_VIEW_HEIGHT)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.right.equalTo(self.contentView).offset(-CONTAINER_PADDING_LEFT)
            make.top.equalTo(self.recordContainer.snp.bottom).offset(5)
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
            make.centerY.equalTo(self.musicContainer)
        }
        
        recordAudioLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.musicLabel)
            make.centerY.equalTo(self.recordContainer)
        }
        
        captionLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.musicLabel)
            make.centerY.equalTo(self.captionContainerView)
        }
        
        addButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.view).offset(-SCREEN_PADDING_X)
            make.centerY.equalTo(self.containerView)
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        loadingView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        muteButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.originAudioLabel.snp.left).offset(-15)
            make.centerY.equalTo(self.originAudioLabel)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
    }
    
    private func clearSplitViewsAndInfos() {
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
        //判断是否包含这两个point
        guard musicContainer.canInsert(from: minPoint, to: maxPoint) else {
            MessageBanner.warning(content: "此位置无法添加音频")
            return
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
    
    private func pushToRecordAudio() {
        let vc = EditToolRecordAudioViewController()
        vc.stopClosure = { [unowned self] (url) in
            self.presenter.toolView(self, addRecordAudioFrom: AVURLAsset(url: url))
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToAddCaption() {
        let vc = EditToolAddCaptionViewController()
        vc.duration = duration
        //因为presenter已经实现了这些协议，所以强行赋值进去
        vc.presenter = presenter as? (EditAddCaptionViewOutput & EditDataSourceProtocol & EditPlayerInteractionProtocol)
        vc.playerStatus = playerStatus
        let offsetX = containerView.contentOffset.x
        let totalWidth = containerView.contentSize.width
        let currentPercent = min(Float(offsetX / (totalWidth - SCREEN_WIDTH)), 1)
        vc.backClosure = { [unowned self] in
            //1.退出时重制到当前的percent
            self.containerView.contentOffset = CGPoint(x: offsetX, y: 0)
            self.presenter.viewIsDraggingWith(with: currentPercent)
            //2.刷新字幕view
            self.captionContainerView.update(self.presenter.captionCellModels)
        }
        let model = EditToolAddCaptionUpdateModel(asset: thumbView.asset, totalWidth: totalWidth, currentOffset: offsetX, contentWidth: videoContentWidth)
        vc.model = model
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToApplyFilters() {
        guard let presenter = presenter as? EditAdjustOutput else { return }
        let vc = EditToolFiltersViewController(presenter: presenter)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToBrightnessAdjust() {
        let vc = EditProgressAdjustViewController()
        let currentBrightness = presenter.currentBrightness
        let info = AdjustProgressViewInfo(startValue: -1.0, endValue: 1.0, currentValue: currentBrightness)
        vc.info = info
        vc.operationChangeClosure = { [unowned self] (value) in
            self.presenter.toolView(self, didChangeBrightness: value)
        }
        vc.operationCancelClosure = { [unowned self] in
            self.presenter.toolView(self, didChangeBrightness: currentBrightness)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToExposureAdjust() {
        let vc = EditProgressAdjustViewController()
        let currentExposure = presenter.currentExposure
        let info = AdjustProgressViewInfo(startValue: -2.0, endValue: 2.0, currentValue: currentExposure)
        vc.info = info
        vc.operationChangeClosure = { [unowned self] (value) in
            self.presenter.toolView(self, didChangeExposure: value)
        }
        vc.operationCancelClosure = { [unowned self] in
            self.presenter.toolView(self, didChangeExposure: currentExposure)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToContrastAdjust() {
        let vc = EditProgressAdjustViewController()
        let currentContrast = presenter.currentContrast
        let info = AdjustProgressViewInfo(startValue: 0, endValue: 4.0, currentValue: currentContrast)
        vc.info = info
        vc.operationChangeClosure = { [unowned self] (value) in
            self.presenter.toolView(self, didChangeContrast: value)
        }
        vc.operationCancelClosure = { [unowned self] in
            self.presenter.toolView(self, didChangeContrast: currentContrast)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToSaturationAdjust() {
        let vc = EditProgressAdjustViewController()
        let currentSaturation = presenter.currentSaturation
        let info = AdjustProgressViewInfo(startValue: 0, endValue: 4.0, currentValue: currentSaturation)
        vc.info = info
        vc.operationChangeClosure = { [unowned self] (value) in
            self.presenter.toolView(self, didChangeSaturation: value)
        }
        vc.operationCancelClosure = { [unowned self] in
            self.presenter.toolView(self, didChangeSaturation: currentSaturation)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func replaceSelectedMusic() {
        guard let segment = (selectedMusicCell?.model as? EditOperationAudioCellModel)?.segment else {
            MessageBanner.warning(content: "当前没有选中音乐")
            return
        }
        let vc = AudioCollectionViewController()
        vc.selectedClosure = { [unowned self] (model) in
            guard let url = model.assetURL else { return }
            let newSegment = CompositionAudioSegment(url: url)
            self.presenter.toolView(self, replaceMusic: segment, for: newSegment)
        }
        let nav = NavigationController(rootViewController: vc)
        UIViewController.qe.current()?.present(nav, animated: true, completion: nil)
    }
    
    private func removeSelectedMusic() {
        guard let model = selectedMusicCell?.model as? EditOperationAudioCellModel else {
            MessageBanner.warning(content: "当前没有选中音乐")
            return
        }
        let segment = model.segment
        let actionSheet = UIAlertController(title: "提示", message: "删除当前选定的音乐", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            self.presenter.toolView(self, removeMusic: segment)
            self.musicContainer.removeCell(for: model)
            MessageBanner.success(content: "删除成功")
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(okAction)
        actionSheet.addAction(cancelAction)
        UIViewController.qe.current()?.present(actionSheet, animated: true, completion: nil)
    }
    
    private func removeSelectedRecord() {
        guard let model = selectedRecordCell?.model as? EditOperationAudioCellModel else {
            MessageBanner.warning(content: "当前没有选中录音")
            return
        }
        let segment = model.segment
        let actionSheet = UIAlertController(title: "提示", message: "删除当前选定的录音", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            self.presenter.toolView(self, removeRecord: segment)
            self.recordContainer.removeCell(for: model)
            MessageBanner.success(content: "删除成功")
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(okAction)
        actionSheet.addAction(cancelAction)
        UIViewController.qe.current()?.present(actionSheet, animated: true, completion: nil)
    }
    
    private func removeSelectedCaption() {
        let actionSheet = UIAlertController(title: "提示", message: "删除当前选定的字幕", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
            guard let model = self.selectedCaptionCell?.model as? EditOperationCaptionCellModel else { return }
            guard let segment = model.segment else { return }
            self.presenter.deleteCaption(segment: segment)
            self.captionContainerView.removeCell(for: model)
            MessageBanner.success(content: "删除成功")
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            
        }
        actionSheet.addAction(okAction)
        actionSheet.addAction(cancelAction)
        UIViewController.qe.current()?.present(actionSheet, animated: true, completion: nil)
    }
    
    private func pushToEditMusic() {
        guard let segment = (selectedMusicCell?.model as? EditOperationAudioCellModel)?.segment else {
            MessageBanner.warning(content: "当前没有选中音乐")
            return
        }
        let vc = EditToolAudioDetailSettingsViewController()
        vc.volumeClosure = { [unowned self] (value) in
            self.presenter.toolView(self, changeMusic: value, of: segment)
        }
        vc.fadeInClosure = { [unowned self] (on) in
            self.presenter.toolView(self, changeMusicFadeIn: on, of: segment)
        }
        vc.fadeOutClosure = { [unowned self] (on) in
            self.presenter.toolView(self, changeMusicFadeOut: on, of: segment)
        }
        vc.chooseClosure = { [unowned self] (start) in
            self.presenter.toolView(self, updateMusic: segment, atNew: start)
        }
        vc.update(segment)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToEditRecord() {
        guard let segment = (selectedRecordCell?.model as? EditOperationAudioCellModel)?.segment else {
            MessageBanner.warning(content: "当前没有选中录音片段")
            return
        }
        let vc = EditToolAudioDetailSettingsViewController()
        vc.isHiddenChoose = true
        vc.volumeClosure = { [unowned self] (value) in
            self.presenter.toolView(self, changeRecord: value, of: segment)
        }
        vc.fadeInClosure = { [unowned self] (on) in
            self.presenter.toolView(self, changeRecordFadeIn: on, of: segment)
        }
        vc.fadeOutClosure = { [unowned self] (on) in
            self.presenter.toolView(self, changeRecordFadeOut: on, of: segment)
        }
        vc.update(segment)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func pushToEditCaption() {
        guard let segment = (self.selectedCaptionCell?.model as? EditOperationCaptionCellModel)?.segment else {
            MessageBanner.warning(content: "当前没有选中字幕片段")
            return
        }
        let vc = EditToolEditCaptionViewController()
        vc.segment = segment
        vc.presenter = presenter as? EditCaptionViewOutput
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
        case .recordAudio:
            pushToRecordAudio()
        case .text:
            pushToAddCaption()
        case .adjust:
            break
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
    
    @objc
    func muteButtonDidClick() {
        muteButton.isSelected = !muteButton.isSelected
        if muteButton.isSelected {
            presenter.toolViewOriginalAudioEnableMute(self)
        } else {
            presenter.toolViewOriginalAudioDisableMute(self)
        }
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
        view.backgroundColor = UIColor.qe.hex(0xFA3E54)
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
            return self.presenter.frameCount()
        }
        view.itemModelClosure = { [unowned self] (item: Int) -> EditToolImageCellModel in
            return self.presenter.thumbModel(at: item)
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
            return self.presenter.frameCount()
        }
        view.itemContentClosure = { [unowned self] (item: Int) -> String in
            return self.presenter.timeContent(at: item)
        }
        return view
    }()
    
    private lazy var captionContainerView: EditOperationContainerView = {
        let view = EditOperationContainerView()
        view.operationFinishClosure = { [unowned self] (cell) in
            guard let segment = (cell.model as? EditOperationCaptionCellModel)?.segment else { return }
            segment.rangeAtComposition = CMTimeRange(start: cell.startValue(for: self.duration), end: cell.endValue(for: self.duration))
            self.presenter.updateCaption(segment: segment)
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
            case .splitVideo:
                self.presenter.toolViewShouldSplitVideo(self)
            case .deleteVideo:
                self.deletePart()
            case .videoChangeSpeed:
                self.pushChangeSpeedView()
            case .videoReverse:
                self.loadingView.show()
                MessageBanner.show(title: "任务", subTitle: "开始执行反转视频任务", style: .info)
                self.presenter.toolViewShouldReverseVideo(self)
            case .replaceMusic:
                self.replaceSelectedMusic()
            case .editMusic:
                self.pushToEditMusic()
            case .deleteMusic:
                self.removeSelectedMusic()
            case .editRecord:
                self.pushToEditRecord()
            case .deleteRecord:
                self.removeSelectedRecord()
            case .deleteCaption:
                self.removeSelectedCaption()
            case .editCaptionStyle:
                self.pushToEditCaption()
            case .editCaption:
                self.pushToAddCaption()
            case .filters:
                self.pushToApplyFilters()
            case .brightnessAdjust:
                self.pushToBrightnessAdjust()
            case .exposureAdjust:
                self.pushToExposureAdjust()
            case .contrastAdjust:
                self.pushToContrastAdjust()
            case .saturationAdjust:
                self.pushToSaturationAdjust()
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
        let view = EditToolTabView()
        view.selectedClosure = { [unowned self] (type) in
            self.tabSelectedType = type
            self.addButton.isHidden = false
            switch type {
            case .edit:
                self.toolBarView.update(self.videoToolBarModels)
            case .music:
                self.toolBarView.update(self.musicToolBarModels)
            case.recordAudio:
                self.toolBarView.update(self.recordToolBarModels)
            case .text:
                self.toolBarView.update(self.textToolBarModels)
            case .adjust:
                self.toolBarView.update(self.adjustToolBarModels)
                self.addButton.isHidden = true
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
    
    private lazy var recordAudioLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "录音轨道"
        return view
    }()
    
    private lazy var captionLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "字幕轨道"
        return view
    }()
    
    private lazy var musicContainer: EditOperationContainerView = {
        let view = EditOperationContainerView()
        view.operationFinishClosure = { [unowned self] (cell) in
            guard let segment = (cell.model as? EditOperationAudioCellModel)?.segment else { return }
            let range = CMTimeRange(start: cell.startValue(for: self.duration), end: cell.endValue(for: self.duration))
            self.presenter.toolView(self, updateMusic: segment, timeRange: range)
        }
        return view
    }()
    
    private lazy var recordContainer: EditOperationContainerView = {
        let view = EditOperationContainerView()
        view.operationFinishClosure = { [unowned self] (cell) in
            guard let segment = (cell.model as? EditOperationAudioCellModel)?.segment else { return }
            let range = CMTimeRange(start: cell.startValue(for: self.duration), end: cell.endValue(for: self.duration))
            self.presenter.toolView(self, updateRecord: segment, timeRange: range)
        }
        return view
    }()
    
    private lazy var muteButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_mute_enable"), for: .selected)
        view.setImage(UIImage(named: "edit_mute_disable"), for: .normal)
        view.addTarget(self, action: #selector(muteButtonDidClick), for: .touchUpInside)
        return view
    }()

}

//MARK: EditToolViewInput
extension EditToolViewController: EditToolViewInput {
    
    func refreshWaveFormView(with asset: AVAsset) {
        originAudioWaveformView.update(asset)
        muteButton.isSelected = presenter.isMute
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
    
    func selectedVideoSegment() -> CompositionVideoSegment? {
        return selectedChooseView?.segment
    }
    
    func refreshOperationContainerView() {
        loadingView.dismiss()
        //视频最大滑动宽度
        let contentWidth = videoContentWidth
        //容器最大滑动宽度
        let containerContentWidth = max(contentWidth + SCREEN_WIDTH, MIN_SCROLL_WIDTH)
        containerView.contentSize = .init(width: containerContentWidth, height: 0)
        contentView.snp.updateConstraints { (make) in
            make.width.equalTo(containerContentWidth)
        }
        view.layoutIfNeeded()
    }
    
    func reloadVideoView(_ segments: [CompositionVideoSegment]) {
        thumbView.reloadData()
        timeScaleView.reloadData()
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
    
    func updatePlayViewStatus(_ status: CompositionPlayerStatus) {
        playerStatus = status
    }
    
    func refreshMusicContainer() {
        musicContainer.update(presenter.musicCellModels)
    }
    
    func refreshRecordContainer() {
        recordContainer.update(presenter.recordCellModels)
    }
    
    func refreshCaptionContainer() {
        captionContainerView.update(presenter.captionCellModels)
    }
    
    func refreshVideoTransitionView(_ segments: [CompositionVideoSegment]) {
        clearSplitViewsAndInfos()
        var left = SCREEN_WIDTH / 2
        var i = 0
        var resetVideoContentWidth = videoContentWidth
        for segment in segments {
            //处理一下边界case
            var chooseWidth = CGFloat(Double(videoContentWidth) * segment.duration / duration)
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
    }
    
}

//MARK: UIScrollViewDelegate
extension EditToolViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let totalWidth = scrollView.contentSize.width
        
        if totalWidth - SCREEN_WIDTH > 0 && playerStatus != .playing {
            let percent = min(Float(offsetX / (totalWidth - SCREEN_WIDTH)), 1)
            presenter.viewIsDraggingWith(with: percent)
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
            presenter.viewIsDraggingWith(with: percent)
        }
        
        presenter.viewDidEndDecelerating()
        
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
        presenter.viewWillBeginDragging()
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
