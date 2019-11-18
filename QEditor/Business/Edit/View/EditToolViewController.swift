//
//  EditToolViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/19.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

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
    
    public var presenter: (EditViewPresenterInput & EditToolViewOutput)!
    
    /// 视频时长
    private var duration: Double = 0
    
    /// 播放器状态
    private var playerStatus: PlayerViewStatus = .error
    
    private var isPlayingBeforeDragging = false
    
    /// 视频最大宽度，每次新增、删除视频需要重新设置这个属性
    private var videoContentWidth: CGFloat = 0
    
    /// 分割信息模型数组
    private var splitInfos: [EditToolSplitInfo] = []
    
    /// 分割部分信息模型数组
    private var partInfos: [EditToolPartInfo] = []
    
    /// 当前锁定的选择框
    private weak var forceChooseView: EditToolChooseBoxView?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        toolBarView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldHiddenSplitViews(_:)), name: ChooseBoxDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(shouldShowSplitViews(_:)), name: ChooseBoxDidHiddenNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initView() {
        view.backgroundColor = .black
        view.addSubview(containerView)
        view.addSubview(verticalTimeLineView)
        view.addSubview(toolBarView)
        containerView.addSubview(contentView)
        contentView.addSubview(thumbView)
        contentView.addSubview(timeScaleView)
        
        containerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.bottom.equalTo(self.toolBarView.snp.top)
        }
        
        verticalTimeLineView.snp.makeConstraints { (make) in
            make.center.equalTo(self.containerView)
            make.width.equalTo(4)
            make.height.equalTo(SCREEN_WIDTH / 3)
        }
        
        toolBarView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(50)
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
        
        timeScaleView.snp.makeConstraints { (make) in
            make.height.equalTo(25)
            make.width.equalTo(SCREEN_WIDTH)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.top.equalTo(self.contentView).offset(0)
        }
    }
    
    private func refreshContainerView() {
        //1.清除
        clearViewsAndInfos()
        //2.更新容器view的contentSize
        //todo:先这么处理
        containerView.contentOffset = .zero
        thumbView.contentOffset = .zero
        let itemCount = presenter.toolImageThumbViewItemsCount(self)
        containerView.contentSize = .init(width: CGFloat(itemCount) * EDIT_THUMB_CELL_SIZE, height: 0)
        let width = max(containerView.contentSize.width + SCREEN_WIDTH, MIN_SCROLL_WIDTH)
        contentView.snp.updateConstraints { (make) in
            make.width.equalTo(width)
        }
        //3.设置视频最大宽度
        videoContentWidth = width - SCREEN_WIDTH
        //4.初始化第一个最大的框选view
        let chooseMaxWidth = videoContentWidth + 50
        let view = EditToolChooseBoxView(with: chooseMaxWidth)
        view.qe.left = SCREEN_WIDTH / 2 - 25
        view.qe.width = chooseMaxWidth
        view.qe.centerY = thumbView.qe.centerY
        view.initializeLeft = view.qe.left
        contentView.insertSubview(view, at: InsertViewLevel.choose.rawValue)
        let info = EditToolPartInfo()
        info.chooseView = view
        info.beginTime = 0
        info.endTime = duration
        info.duration = duration
        partInfos.append(info)
        view.info = info
    }
    
    private func resetChooseViews() {
        //1.删除旧的
        partInfos.forEach { (info) in
            info.chooseView?.removeFromSuperview()
        }
        partInfos.removeAll()
        //2.增加新的
        var lastInfo: EditToolSplitInfo?
        splitInfos.forEach { [weak self] (info) in
            let view = EditToolChooseBoxView(with: info.point.x - CONTAINER_PADDING_LEFT)
            if lastInfo == nil {
                view.qe.left = CONTAINER_PADDING_LEFT - 25
                view.qe.width = (info.point.x - CONTAINER_PADDING_LEFT) + 50
            } else {
                view.qe.left = lastInfo!.point.x - 25
                view.qe.width = (info.point.x - lastInfo!.point.x) + 50
            }
            view.qe.centerY = thumbView.qe.centerY
            view.initializeLeft = view.qe.left
            guard let ss = self else {
                return
            }
            ss.contentView.insertSubview(view, at: InsertViewLevel.choose.rawValue)
            let partInfo = EditToolPartInfo()
            partInfo.chooseView = view
            partInfo.beginTime = lastInfo?.videoPoint ?? 0
            partInfo.endTime = info.videoPoint
            partInfo.duration = partInfo.endTime - partInfo.beginTime
            ss.partInfos.append(partInfo)
            view.info = partInfo
            lastInfo = info
        }
        
        let view = EditToolChooseBoxView(with: lastInfo!.point.x - CONTAINER_PADDING_LEFT)
        view.qe.left = lastInfo!.point.x - 25
        view.qe.width = (containerView.contentSize.width - CONTAINER_PADDING_LEFT - lastInfo!.point.x) + 50
        view.qe.centerY = thumbView.qe.centerY
        view.initializeLeft = view.qe.left
        contentView.insertSubview(view, at: InsertViewLevel.choose.rawValue)
        let partInfo = EditToolPartInfo()
        partInfo.chooseView = view
        partInfo.beginTime = lastInfo?.videoPoint ?? 0
        partInfo.endTime = duration
        partInfo.duration = partInfo.endTime - partInfo.beginTime
        partInfos.append(partInfo)
        view.info = partInfo
    }
    
    private func clearViewsAndInfos() {
        contentView.subviews.forEach { (view) in
            if view.isKind(of: EditToolChooseBoxView.self) ||
                view.isKind(of: EditToolSplitView.self) {
                view.removeFromSuperview()
            }
        }
        partInfos.removeAll()
        splitInfos.removeAll()
    }
    
    //MARK: 通知
    @objc
    func shouldHiddenSplitViews(_ notification: Notification) {
        splitInfos.forEach { (info) in
            info.view?.isHidden = true
        }
        let obj = notification.object as? EditToolChooseBoxView
        forceChooseView = obj
        partInfos.forEach { (info) in
            guard info.chooseView != nil else {
                return
            }
            if !info.chooseView!.isEqual(obj) {
                info.chooseView?.hidden()
            }
        }
    }
    
    @objc
    func shouldShowSplitViews(_ notification: Notification) {
        forceChooseView = nil
        splitInfos.forEach { (info) in
            info.view?.isHidden = false
        }
        partInfos.forEach { (info) in
            info.chooseView?.hidden()
        }
    }
    
    //MARK: 工具栏
    
    private func showEditBar() {
        let view = EditToolEditBar()
        view.selectedDelegate = self
        view.frame = .init(x: 0, y: 0, width: toolBarView.qe.width, height: toolBarView.qe.height)
        toolBarView.insertSubview(view, at: 99)
        view.backClosure = { [weak view] in
            view?.removeFromSuperview()
        }
        view.reloadData()
    }
    
    //MARK: Getter
    
    lazy var containerView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.contentSize = .init(width: MIN_SCROLL_WIDTH, height: 0)
        view.delegate = self
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var verticalTimeLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 2
        return view
    }()
    
    lazy var thumbView: EditToolImageThumbView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = EditToolImageThumbView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: EDIT_THUMB_CELL_SIZE), collectionViewLayout: layout)
        view.isScrollEnabled = false
        view.itemCountClosure = { [weak self] in
            if let ss = self {
                return ss.presenter.toolImageThumbViewItemsCount(ss)
            }
            return 0
        }
        view.itemModelClosure = { [weak self] (item: Int) -> EditToolImageCellModel in
            if let ss = self {
                return ss.presenter.toolView(ss, thumbModelAt: item)
            }
            return EditToolImageCellModel()
        }
        return view
    }()
    
    lazy var timeScaleView: EditToolTimeScaleView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = EditToolTimeScaleView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 25), collectionViewLayout: layout)
        view.itemCountClosure = { [weak self] in
            if let ss = self {
                return ss.presenter.toolImageThumbViewItemsCount(ss)
            }
            return 0
        }
        view.itemContentClosure = { [weak self] (item: Int) -> String in
            if let ss = self {
                return ss.presenter.toolView(ss, contentAt: item)
            }
            return ""
        }
        return view
    }()
    
    lazy var toolBarView: EditToolBar = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 15
        layout.itemSize = .init(width: 40, height: 50)
        let view = EditToolBar(frame: .zero, collectionViewLayout: layout)
        view.selectedClosure = { [weak self] (_ index: Int) in
            guard let ss = self else {
                return
            }
            switch index {
            case 0:
                ss.showEditBar()
            default:
                break
            }
        }
        return view
    }()

}

extension EditToolViewController: EditToolEditBarDelegate {
    
    func viewDidSelectedCut(_ view: EditToolEditBar) {
        //[剪辑][分割]
        //分割规则，不能分割1s以内的视频，距离左边或右边分割点1s内的都不行
        //1.判断是否符合分割规则
        //找到第一个比它大的点
        let offsetX = containerView.contentOffset.x
        let totalWidth = containerView.contentSize.width
        let percent = min(Float(offsetX / (totalWidth - SCREEN_WIDTH)), 1)
        let videoPoint = Double(duration) * Double(percent)
        var rightFlag = Int.max
        var leftFlag = Int.min
        for (i, info) in splitInfos.enumerated() {
            if info.videoPoint > videoPoint {
                rightFlag = i
                leftFlag = i - 1
                break
            }
        }
        if rightFlag == Int.max {
            leftFlag = splitInfos.count
        }
        //判断是否可以分割
        if splitInfos.count > 0 {
            if 0 <= rightFlag && rightFlag <= splitInfos.count - 1 {
                let rightInfo = splitInfos[rightFlag]
                if rightInfo.videoPoint - videoPoint <= 1 {
                    QELog("不可以分割这么短的内容哟")
                    return
                }
            }
            if 0 <= leftFlag && leftFlag <= splitInfos.count - 1 {
                let leftInfo = splitInfos[leftFlag]
                if videoPoint - leftInfo.videoPoint <= 1 {
                    QELog("不可以分割这么短的内容哟")
                    return
                }
            }
        } else {
            if videoPoint <= 1 || videoPoint >= Double(duration) - 1 {
                QELog("不可以分割这么短的内容哟")
                return
            }
        }
        //2.初始化分割view
        let view = EditToolSplitView()
        let point = CGPoint(x: containerView.contentOffset.x + CONTAINER_PADDING_LEFT, y: thumbView.qe.centerY)
        view.center = point
        contentView.insertSubview(view, at: InsertViewLevel.splitFlag.rawValue)
        //3.初始化分割模型
        let info = EditToolSplitInfo()
        info.point = point
        info.view = view
        info.videoPoint = videoPoint
        splitInfos.insert(info, at: max(0, leftFlag))
        //4.重新设置框选view
        resetChooseViews()
    }
    
    func viewDidSelectedDelete(_ view: EditToolEditBar) {
        //[剪辑][删除]
        //1.校验是否有选定视频
        guard forceChooseView != nil else {
            QELog("当前没有选定视频，无法删除!")
            return
        }
        //2.删除选定视频
        let deleteInfo = forceChooseView!.info
        guard deleteInfo != nil else {
            return
        }
        partInfos.removeAll { (info) -> Bool in
            info.beginTime == deleteInfo!.beginTime
        }
        //3.抛给presenter删除
        presenter.toolView(self, deletePartFrom: partInfos)
    }
    
}

extension EditToolViewController: EditToolViewInput {
    
}

extension EditToolViewController: EditViewPresenterOutput {
    
    func presenterViewShouldReload(_ presenter: EditViewPresenterInput) {
        refreshContainerView()
        thumbView.reloadData()
        timeScaleView.reloadData()
    }
    
    func presenter(_ presenter: EditViewPresenterInput, playerDidLoadVideoWith duration: Double) {
        self.duration = duration
    }
    
    func presenter(_ presenter: EditViewPresenterInput, playerPlayAt time: Double) {
        guard duration > 0 else {
            return
        }
        let percent = CGFloat(time) / CGFloat(duration)
        guard percent <= 1 else {
            return
        }
        let totalWidth = thumbView.contentSize.width
        let offsetX = totalWidth * percent
        containerView.contentOffset = .init(x: offsetX, y: 0)
    }
    
    func presenter(_ presenter: EditViewPresenterInput, playerStatusDidChange status: PlayerViewStatus) {
        playerStatus = status
    }
    
    func presenter(_ presenter: EditViewPresenterInput, didLoadVideo model: EditVideoModel) {
        thumbView.videoModel = model
    }
    
}

extension EditToolViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let totalWidth = scrollView.contentSize.width
        
        if totalWidth - SCREEN_WIDTH > 0 && playerStatus != .playing {
            let percent = min(Float(offsetX / (totalWidth - SCREEN_WIDTH)), 1)
            presenter.toolView(self, onDragWith: percent)
        }
        
        if offsetX < SCREEN_WIDTH / 2 {
            //在左侧
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            thumbView.contentOffset = .zero
            timeScaleView.contentOffset = .zero
        } else if offsetX >= totalWidth - SCREEN_WIDTH * 1.5 {
            //在右侧
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            thumbView.contentOffset = .init(x: thumbView.contentSize.width - SCREEN_WIDTH, y: 0)
            timeScaleView.contentOffset = .init(x: timeScaleView.contentSize.width - SCREEN_WIDTH, y: 0)
        } else if offsetX >= SCREEN_WIDTH / 2 {
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            let newOffsetX = offsetX - SCREEN_WIDTH / 2
            thumbView.contentOffset = .init(x: newOffsetX, y: 0)
            timeScaleView.contentOffset = .init(x: newOffsetX, y: 0)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let totalWidth = scrollView.contentSize.width
        if totalWidth - SCREEN_WIDTH > 0 {
            let percent = Float(offsetX / (totalWidth - SCREEN_WIDTH))
            presenter.toolView(self, onDragWith: percent)
        }
        if isPlayingBeforeDragging {
            isPlayingBeforeDragging = false
            presenter.playerShouldPlay()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isPlayingBeforeDragging = playerStatus == .playing
        presenter.playerShouldPause()
    }
    
}