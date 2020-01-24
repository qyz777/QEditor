//
//  EditToolViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    /// 当前锁定的选择框
    private weak var forceChooseView: EditToolChooseBoxView?
    
    private var toolBarModels: [EditToolBarModel] = [
        EditToolBarModel(action: .split, imageName: "edit_split", text: "分割"),
        EditToolBarModel(action: .delete, imageName: "edit_delete", text: "删除"),
        EditToolBarModel(action: .changeSpeed, imageName: "edit_speed", text: "变速"),
        EditToolBarModel(action: .reverse, imageName: "edit_reverse", text: "倒放"),
    ]
    
    private var tabSelectedType: EditToolTabSelectedType = .edit
    
    //MARK: Override

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        updateToolBar()
        
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
        contentView.addSubview(waveformView)
        contentView.addSubview(timeScaleView)
        
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
            make.width.equalTo(4)
            make.height.equalTo(SCREEN_WIDTH / 3)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.containerView)
            make.height.equalTo(self.containerView)
            make.width.equalTo(self.containerView.contentSize.width)
        }
        
        thumbView.snp.makeConstraints { (make) in
            make.height.equalTo(EDIT_THUMB_CELL_SIZE)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.width.equalTo(SCREEN_WIDTH)
            make.centerY.equalTo(self.contentView)
        }
        
        waveformView.snp.makeConstraints { (make) in
            make.height.equalTo(WAVEFORM_HEIGHT)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.width.equalTo(SCREEN_WIDTH)
            make.top.equalTo(self.thumbView.snp.bottom).offset(5)
        }
        
        timeScaleView.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(SCREEN_WIDTH)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.top.equalTo(self.contentView).offset(0)
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
    
    private func refreshContainerView(_ segments: [EditCompositionSegment]) {
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
            forceChooseView = view
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
    
    private func updateToolBar() {
        switch tabSelectedType {
        case .edit:
            toolBarView.update(toolBarModels)
        case .music:
            //音乐暂时先不做
            break
        }
    }
    
    private func pushChangeSpeedView() {
        let vc = EditToolChangeSpeedViewController()
        vc.closure = { [unowned self] (progress) in
            guard let forceChooseView = self.forceChooseView else {
                return
            }
            guard let segment = forceChooseView.segment else {
                return
            }
            self.presenter.toolView(self, didChangeSpeedAt: segment, of: progress)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: Action
    
    @objc
    func thumbViewLoadImagesIfScrollStop() {
        thumbView.loadImages()
    }
    
    @objc
    func didClickAddButton() {
        let vc = MediaViewController.buildView()
        vc.completion = { [unowned self] (_ videos: [MediaVideoModel], _ photos: [MediaImageModel]) in
            self.presenter.toolView(self, didSelected: videos, images: photos)
        }
        let nav = NavigationController(rootViewController: vc)
        UIViewController.qe.current()?.present(nav, animated: true, completion: nil)
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
        forceChooseView = obj
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
        forceChooseView = nil
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
        view.layer.cornerRadius = 2
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
    
    private lazy var waveformView: EditToolAudioWaveFormView = {
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
        let width = (SCREEN_WIDTH - 60 - 30 * 3) / 4
        layout.itemSize = .init(width: width, height: 60)
        let view = EditToolBar(frame: .zero, collectionViewLayout: layout)
        view.contentInset = .init(top: 0, left: 30, bottom: 0, right: 30)
        view.selectedClosure = { [unowned self] (model) in
            switch model.action {
            case .split:
                self.presenter.toolViewShouldSplitVideo(self)
            case .delete:
                self.deletePart()
            case .changeSpeed:
                self.pushChangeSpeedView()
            case .reverse:
                self.loadingView.show()
                self.presenter.toolViewShouldReverseVideo(self)
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
        }
        return view
    }()
    
    private lazy var loadingView: EditToolSettingLoadingView = {
        let view = EditToolSettingLoadingView(frame: .zero)
        view.isHidden = true
        return view
    }()

}

//MARK: EditToolViewInput
extension EditToolViewController: EditToolViewInput {
    
    func refreshWaveFormView(with box: [[CGFloat]]) {
        waveformView.contentSize = .init(width: thumbView.contentSize.width, height: 0)
        waveformView.update(box)
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
        let deleteSegment = forceChooseView!.segment
        guard deleteSegment != nil else {
            return
        }
        //3.抛给presenter删除
        presenter.toolView(self, delete: deleteSegment!)
    }
    
    func showChangeBrightnessView(_ info: AdjustProgressViewInfo) {
        if let progressView = showAdjustView(info) {
            progressView.closure = { [unowned self] (progress) in
                guard let forceChooseView = self.forceChooseView else {
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
                guard let forceChooseView = self.forceChooseView else {
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
                guard let forceChooseView = self.forceChooseView else {
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
                guard let forceChooseView = self.forceChooseView else {
                    return
                }
                guard let segment = forceChooseView.segment else {
                    return
                }
                self.presenter.toolView(self, didChangeGaussianBlurFrom: segment.rangeAtComposition.start.seconds, to: segment.rangeAtComposition.end.seconds, of: progress)
            }
        }
    }
    
    func forceSegment() -> EditCompositionSegment? {
        return forceChooseView?.segment
    }
    
    func reloadView(_ segments: [EditCompositionSegment]) {
        refreshContainerView(segments)
        thumbView.reloadData()
        timeScaleView.reloadData()
    }
    
    func refreshView(_ segments: [EditCompositionSegment]) {
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
            waveformView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            thumbView.contentOffset = .zero
            timeScaleView.contentOffset = .zero
            waveformView.contentOffset = .zero
        } else if offsetX >= SCREEN_WIDTH / 2 && offsetX < totalWidth - SCREEN_WIDTH * 1.5 {
            //在中间滚动
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            waveformView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            let newOffsetX = offsetX - SCREEN_WIDTH / 2
            thumbView.contentOffset = .init(x: newOffsetX, y: 0)
            timeScaleView.contentOffset = .init(x: newOffsetX, y: 0)
            waveformView.contentOffset = .init(x: newOffsetX, y: 0)
        } else {
            //在右侧滚动
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            waveformView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            thumbView.contentOffset = .init(x: thumbView.contentSize.width - SCREEN_WIDTH, y: 0)
            timeScaleView.contentOffset = .init(x: timeScaleView.contentSize.width - SCREEN_WIDTH, y: 0)
            waveformView.contentOffset = .init(x: waveformView.contentSize.width - SCREEN_WIDTH, y: 0)
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
