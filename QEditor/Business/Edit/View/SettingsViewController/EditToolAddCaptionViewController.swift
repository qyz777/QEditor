//
//  EditToolAddCaptionViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/22.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation

struct EditToolAddCaptionUpdateModel {
    let asset: AVAsset?
    let totalWidth: CGFloat
    let currentOffset: CGFloat
    let contentWidth: CGFloat
}

class EditToolAddCaptionViewController: EditToolBaseSettingsViewController {
    
    var playerStatus: CompositionPlayerStatus = .stop
    
    var duration: Double = 0
    
    var backClosure: (() -> Void)?
    
    var addView: UIView?
    
    var presenter: (EditPlayerInteractionProtocol & EditDataSourceProtocol & EditAddCaptionViewOutput)! {
        willSet {
            newValue.setupAddCaptionView(self)
        }
    }
    
    var model: EditToolAddCaptionUpdateModel? {
        willSet {
            guard let m = newValue else { return }
            thumbView.asset = m.asset
            thumbView.reloadData()
            view.layoutIfNeeded()
            containerView.contentSize = CGSize(width: m.totalWidth, height: 0)
            containerView.contentOffset = CGPoint(x: m.currentOffset, y: 0)
            contentView.snp.updateConstraints { (make) in
                make.width.equalTo(m.totalWidth)
            }
            view.layoutIfNeeded()
            operationContainerView.update(presenter.captionCellModels)
        }
    }
    
    private var beginLongPress = false
    private var startRecordX: CGFloat = 0
    
    private var selectedCell: EditOperationCaptionCell? {
        return operationContainerView.selectedCell as? EditOperationCaptionCell
    }
    
    private var cannotPop: Bool {
        return beginLongPress || presenter.isEditingCaption
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.isHidden = true
        initView()
    }
    
    override func backButtonTouchUpIndside() {
        guard !cannotPop else {
            return
        }
        backClosure?()
        super.backButtonTouchUpIndside()
    }
    
    override func operationDidFinish() {
        guard !cannotPop else {
            return
        }
        backButtonTouchUpIndside()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var isPop = true
        var i = 0
        let viewControllers = navigationController?.viewControllers ?? []
        for vc in viewControllers {
            if vc.self == self.self && i < viewControllers.count {
                isPop = false
            }
            i += 1
        }
        if isPop {
            backClosure?()
        }
    }
    
    //MARK: Action
    
    @objc
    private func longPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            startRecordX = containerView.contentOffset.x + CONTAINER_PADDING_LEFT
            //判定违规区域
            for model in presenter.captionCellModels {
                let start = model.start + CONTAINER_PADDING_LEFT
                if start <= startRecordX && startRecordX <= start + model.width {
                    MessageBanner.warning(content: "不能在此区域添加字幕")
                    return
                }
            }
            addView = UIView(frame: CGRect(x: startRecordX, y: thumbView.frame.maxY + 5, width: 1, height: EDIT_OPERATION_VIEW_HEIGHT))
            addView?.backgroundColor = UIColor.qe.hex(0x222222)
            addView?.layer.cornerRadius = 4
            contentView.addSubview(addView!)
            beginLongPress = true
            presenter.beginAddCaption()
        case .ended, .failed, .cancelled:
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            guard let addView = addView else { return }
            //设置字幕cellModel
            let cellModel = EditOperationCaptionCellModel()
            cellModel.start = addView.x - CONTAINER_PADDING_LEFT
            cellModel.width = addView.width
            cellModel.maxWidth = operationContainerView.width
            
            self.addView?.removeFromSuperview()
            self.addView = nil
            beginLongPress = false
            presenter.endAddCaption()
            
            guard cellModel.width >= EDIT_OPERATION_VIEW_MIN_WIDTH else {
                MessageBanner.error(content: "无法添加不足1s的字幕")
                return
            }
            
            //寻找插入位置
            var i = 0
            for model in presenter.captionCellModels {
                if model.start + model.width <= cellModel.start {
                    i += 1
                } else {
                    break
                }
            }
            operationContainerView.insertCell(from: cellModel, at: i)
            
            guard let t = operationContainerView.range(for: cellModel, in: duration) else { return }
            presenter.addCaptionText(nil, start: t.start, end: t.end)
        default:
            navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            break
        }
    }
    
    @objc
    private func cancelButtonTouchUpInside() {
        cancelButton.removeFromSuperview()
        toolView.removeFromSuperview()
        self.selectedCell?.hiddenOperationView()
    }
    
    //MARK: Private
    
    private func initView() {
        view.addSubview(containerView)
        view.addSubview(verticalTimeLineView)
        view.addSubview(self.addButton)
        containerView.addSubview(contentView)
        contentView.addSubview(thumbView)
        contentView.addSubview(timeScaleView)
        contentView.addSubview(operationContainerView)
        
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.topBar.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.addButton.snp.top).offset(-10)
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
        operationContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(self.thumbView.snp.bottom).offset(5)
            make.height.equalTo(EDIT_OPERATION_VIEW_HEIGHT)
            make.left.equalTo(self.contentView).offset(CONTAINER_PADDING_LEFT)
            make.right.equalTo(self.contentView).offset(-CONTAINER_PADDING_LEFT)
        }
        addButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).offset(-11)
            make.centerX.equalTo(self.view)
            make.height.equalTo(44)
            make.width.equalTo(100)
        }
    }
    
    //MARK: Getter
    
    lazy var containerView: UIScrollView = {
        let view = UIScrollView()
        view.showsHorizontalScrollIndicator = false
        view.contentSize = CGSize(width: MIN_SCROLL_WIDTH, height: 0)
        view.delegate = self
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
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
            return self.presenter.frameCount()
        }
        view.itemModelClosure = { [unowned self] (item: Int) -> EditToolImageCellModel in
            return self.presenter.thumbModel(at: item)
        }
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
    
    private lazy var operationContainerView: EditOperationContainerView = {
        let view = EditOperationContainerView()
        view.selectedClosure = { [unowned self, view] (isSelected) in
            self.toolView.removeFromSuperview()
            self.cancelButton.removeFromSuperview()
            guard isSelected else { return }
            let center = view.convert(self.selectedCell?.center ?? .zero, to: self.contentView)
            self.contentView.addSubview(self.toolView)
            self.contentView.addSubview(self.cancelButton)
            self.toolView.snp.makeConstraints { (make) in
                make.top.equalTo(view.snp.bottom).offset(5)
                make.centerX.equalTo(self.contentView.snp.left).offset(center.x)
            }
            self.cancelButton.snp.remakeConstraints { (make) in
                make.left.equalTo(self.toolView.snp.right).offset(10)
                make.centerY.equalTo(self.toolView)
            }
        }
        view.operationFinishClosure = { [unowned self] (cell) in
            guard let segment = (cell.model as? EditOperationCaptionCellModel)?.segment else { return }
            segment.rangeAtComposition = CMTimeRange(start: cell.startValue(for: self.duration), end: cell.endValue(for: self.duration))
            self.presenter.updateCaption(segment: segment)
        }
        return view
    }()
    
    private lazy var addButton: UIButton = {
        let view = UIButton(type: .custom)
        view.backgroundColor = UIColor.qe.hex(0xFA3E54)
        view.layer.cornerRadius = 4
        view.setTitle("长按添加字幕", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        view.addGestureRecognizer(gesture)
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "edit_red_cancel"), for: .normal)
        view.addTarget(self, action: #selector(cancelButtonTouchUpInside), for: .touchUpInside)
        return view
    }()
    
    private lazy var toolView: EditCaptionCellToolView = {
        let view = EditCaptionCellToolView(frame: .zero)
        view.deleteClosure = { [unowned self, view] in
            guard let model = self.selectedCell?.model as? EditOperationCaptionCellModel else { return }
            guard let segment = model.segment else { return }
            self.presenter.deleteCaption(segment: segment)
            self.operationContainerView.removeCell(for: model)
            view.removeFromSuperview()
            self.cancelButton.removeFromSuperview()
        }
        view.editClosure = { [unowned self] in
            guard let segment = (self.selectedCell?.model as? EditOperationCaptionCellModel)?.segment else { return }
            let vc = EditToolEditCaptionViewController()
            vc.segment = segment
            vc.presenter = self.presenter as? EditCaptionViewOutput
            self.navigationController?.pushViewController(vc, animated: true)
        }
        view.updateClosure = { [unowned self, view] in
            guard let model = self.selectedCell?.model as? EditOperationCaptionCellModel else { return }
            guard let segment = model.segment else { return }
            self.presenter.editCaptionText(for: segment)
            view.removeFromSuperview()
            self.cancelButton.removeFromSuperview()
        }
        return view
    }()

}

//MARK: EditAddCaptionViewInput

extension EditToolAddCaptionViewController: EditAddCaptionViewInput {
    
    func updatePlayViewStatus(_ status: CompositionPlayerStatus) {
        playerStatus = status
    }
    
    func updateDuration(_ duration: Double) {
        self.duration = duration
    }
    
    func updatePlayTime(_ time: Double) {
        guard duration > 0 && model != nil else {
            return
        }
        let percent = CGFloat(time) / CGFloat(duration)
        guard percent <= 1 else {
            return
        }
        let totalWidth = model!.contentWidth
        let offsetX = totalWidth * percent
        containerView.contentOffset = .init(x: offsetX, y: 0)
    }
    
    func refreshCaptionContainerView() {
        operationContainerView.update(presenter.captionCellModels)
    }
    
}

//MARK: UIScrollViewDelegate

extension EditToolAddCaptionViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x
        let totalWidth = scrollView.contentSize.width
        if !beginLongPress {
            if totalWidth - SCREEN_WIDTH > 0 && playerStatus != .playing {
                let percent = min(Float(offsetX / (totalWidth - SCREEN_WIDTH)), 1)
                presenter.viewIsDraggingWith(with: percent)
            }
        }
        
        if addView != nil {
            let currentX = containerView.contentOffset.x + CONTAINER_PADDING_LEFT
            let newWidth = max(1, currentX - startRecordX)
            if presenter.captionCellModels.count > 0 {
                var findFlag = false
                for model in presenter.captionCellModels {
                    //找到新增cell的后面一个判断长度添加是否合法
                    if model.start > addView!.x {
                        findFlag = true
                        if addView!.x + newWidth <= model.start {
                            addView?.width = newWidth
                        } else {
                            MessageBanner.info(content: "以达到当前可添加的最大长度")
                            presenter.endAddCaption()
                        }
                        break
                    }
                }
                if !findFlag {
                    addView?.width = newWidth
                }
            } else {
                addView?.width = newWidth
            }
        }
        
        if offsetX < SCREEN_WIDTH / 2 {
            //在左侧滚动
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(SCREEN_WIDTH / 2)
            }
            thumbView.contentOffset = .zero
            timeScaleView.contentOffset = .zero
        } else if offsetX >= SCREEN_WIDTH / 2 && offsetX < totalWidth - SCREEN_WIDTH * 1.5 {
            //在中间滚动
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(offsetX)
            }
            let newOffsetX = offsetX - SCREEN_WIDTH / 2
            thumbView.contentOffset = .init(x: newOffsetX, y: 0)
            timeScaleView.contentOffset = .init(x: newOffsetX, y: 0)
        } else {
            //在右侧滚动
            thumbView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            timeScaleView.snp.updateConstraints { (make) in
                make.left.equalTo(self.contentView).offset(totalWidth - SCREEN_WIDTH * 1.5)
            }
            thumbView.contentOffset = .init(x: thumbView.contentSize.width - SCREEN_WIDTH, y: 0)
            timeScaleView.contentOffset = .init(x: timeScaleView.contentSize.width - SCREEN_WIDTH, y: 0)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard !beginLongPress else {
            return
        }
        let offsetX = scrollView.contentOffset.x
        let totalWidth = scrollView.contentSize.width
        if totalWidth - SCREEN_WIDTH > 0 {
            let percent = Float(offsetX / (totalWidth - SCREEN_WIDTH))
            presenter.viewIsDraggingWith(with: percent)
        }
        presenter.viewDidEndDecelerating()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard !beginLongPress else {
            return
        }
        presenter.viewWillBeginDragging()
    }
    
}
