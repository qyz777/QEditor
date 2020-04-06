//
//  EditOperationContainerView.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/2/23.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

let EDIT_OPERATION_VIEW_MIN_WIDTH: CGFloat = 40
let EDIT_OPERATION_VIEW_HEIGHT: CGFloat = 30

protocol EditOperationCellModel {
    
    var width: CGFloat { set get}
    
    var cellClass: AnyClass { set get }
    
    var start: CGFloat { set get }
    
    var maxWidth: CGFloat { set get }
    
}

class EditOperationContainerView: UIView {

    private var cells: [EditOperationCell] = []
    
    public var operationFinishClosure: ((_ cell: EditOperationCell) -> Void)?
    
    public var selectedClosure: ((_ isSelected: Bool) -> Void)?
    
    public var selectedCell: EditOperationCell?
    
    //MARK: Public
    
    public func canInsert(from start: CGPoint, to end: CGPoint) -> Bool {
        for cell in cells {
            if cell.frame.contains(start) || cell.frame.contains(end) {
                return false
            }
        }
        return true
    }
    
    @discardableResult
    public func appendCell(from cellModel: EditOperationCellModel) -> Bool {
        guard cellModel.cellClass.isSubclass(of: EditOperationCell.self) || cellModel.cellClass == EditOperationCell.self else {
            return false
        }
        guard cellModel.start >= 0 && cellModel.start + cellModel.width <= self.width else {
            return false
        }
        let cellType = cellModel.cellClass as! UIView.Type
        let cell = cellType.init(frame: CGRect(x: 0, y: 0, width: cellModel.width, height: self.height)) as! EditOperationCell
        cells.append(cell)
        cell.update(cellModel)
        setupCell(cell)
        return true
    }
    
    @discardableResult
    public func insertCell(from cellModel: EditOperationCellModel, at index: Int) -> Bool {
        guard cellModel.cellClass.isSubclass(of: EditOperationCell.self) || cellModel.cellClass == EditOperationCell.self else {
            return false
        }
        if index - 1 >= 0 {
            let preCell = cells[index - 1]
            if preCell.frame.maxX > cellModel.start {
                return false
            }
        }
        if index + 1 < cells.count {
            let nextCell = cells[index + 1]
            if nextCell.x < cellModel.start + cellModel.width {
                return false
            }
        }
        let cellType = cellModel.cellClass as! UIView.Type
        let cell = cellType.init(frame: CGRect(x: 0, y: 0, width: cellModel.width, height: self.height)) as! EditOperationCell
        cells.insert(cell, at: index)
        cell.update(cellModel)
        setupCell(cell)
        return true
    }
    
    @discardableResult
    public func removeCell(for cellModel: EditOperationCellModel) -> Bool {
        guard cells.count > 0 else {
            return false
        }
        let preCount = cells.count
        cells.removeAll { (c) -> Bool in
            guard let m = c.model else { return false }
            if m.start == cellModel.start && m.cellClass == cellModel.cellClass {
                c.removeFromSuperview()
                return true
            }
            return false
        }
        return preCount != cells.count
    }
    
    public func update(_ cellModels: [EditOperationCellModel]) {
        cells.forEach {
            $0.removeFromSuperview()
        }
        cells.removeAll()
        cellModels.forEach {
            appendCell(from: $0)
        }
    }
    
    public func range(for cellModel: EditOperationCellModel, in duration: Double) -> (start: Double, end: Double)? {
        for cell in cells {
            guard let model = cell.model else { continue }
            if model.start == cellModel.start && model.width == cellModel.width {
                let start = cell.startValue(for: duration)
                let end = cell.endValue(for: duration)
                guard start >= 0 && end > 0 else {
                    return nil
                }
                return (start: start, end: end)
            }
        }
        return nil
    }
    
    
    public func range(for cell: EditOperationCell, in duration: Double) -> (start: Double, end: Double)? {
        guard let cellModel = cell.model else { return nil }
        for cell in cells {
            guard let model = cell.model else { continue }
            if model.start == cellModel.start && model.width == cellModel.width {
                let start = cell.startValue(for: duration)
                let end = cell.endValue(for: duration)
                guard start >= 0 && end > 0 else {
                    return nil
                }
                return (start: start, end: end)
            }
        }
        return nil
    }
    
    //MARK: Private
    
    private func setupCell(_ cell: EditOperationCell) {
        var preCell: EditOperationCell?
        var nextCell: EditOperationCell?
        for i in 0..<cells.count {
            if cells[i].isEqual(cell) {
                if i > 0 {
                    preCell = cells[i - 1]
                }
                if i + 1 < cells.count {
                    nextCell = cells[i + 1]
                }
            }
        }
        cell.selectedClosure = { [unowned self, cell] (isSelected) in
            for view in self.cells {
                if !view.isEqual(cell) {
                    view.hiddenOperationView()
                }
            }
            if isSelected {
                self.selectedCell = cell
            } else {
                self.selectedCell = nil
            }
            self.selectedClosure?(isSelected)
        }
        var currentX = cell.x
        var currentWidth = cell.width
        cell.handleLeftPanClosure = { [unowned self, cell] (pan) in
            switch pan.state {
            case .began:
                currentX = cell.x
                currentWidth = cell.width
            case .changed:
                //1.检查条件
                let offsetX = pan.translation(in: cell).x
                let newLeft: CGFloat
                if offsetX < 0 {
                    //向左
                    newLeft = max(preCell != nil ? preCell!.frame.maxX : 0, currentX + offsetX)
                } else {
                    //向右
                    newLeft = min(cell.frame.maxX - EDIT_OPERATION_VIEW_MIN_WIDTH, currentX + offsetX)
                }
                let newWidth = currentWidth + currentX - newLeft
                guard newWidth <= cell.model!.maxWidth else { return }
                //2.开始移动
                cell.snp.updateConstraints { (make) in
                    make.left.equalTo(self).offset(newLeft)
                    make.width.equalTo(newWidth)
                }
                cell.layoutIfNeeded()
            case .ended:
                self.operationFinishClosure?(cell)
            default:
                break
            }
        }
        cell.handleRightPanClosure = { [unowned self, cell] (pan) in
            switch pan.state {
            case .began:
                currentX = cell.frame.maxX
                currentWidth = cell.width
            case .changed:
                //1.检查条件
                let offsetX = pan.translation(in: cell).x
                let newRight: CGFloat
                if offsetX < 0 {
                    //向左
                    newRight = max(cell.x + EDIT_OPERATION_VIEW_MIN_WIDTH, currentX + offsetX)
                } else {
                    //向右
                    newRight = min(nextCell != nil ? nextCell!.x : self.width - 0, currentX + offsetX)
                }
                var newWidth = newRight - cell.x
                newWidth = min(newWidth, cell.model!.maxWidth)
                //2.开始移动
                cell.snp.updateConstraints { (make) in
                    make.width.equalTo(newWidth)
                }
                cell.layoutIfNeeded()
            case .ended:
                self.operationFinishClosure?(cell)
            default:
                break
            }
        }
        addSubview(cell)
        cell.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.left.equalTo(self).offset(cell.model!.start)
            make.width.equalTo(cell.model!.width)
            make.height.equalTo(EDIT_OPERATION_VIEW_HEIGHT)
        }
    }

}

//MARK: EditOperationCell

class EditOperationCell: UIView {
    
    public private(set) var isSelected = false
    
    public var model: EditOperationCellModel?
    
    var selectedClosure: ((_ isSelected: Bool) -> Void)?
    
    var handleLeftPanClosure: ((_ pan: UIPanGestureRecognizer) -> Void)?
    
    var handleRightPanClosure: ((_ pan: UIPanGestureRecognizer) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(leftPanView)
        addSubview(rightPanView)
        addSubview(coverView)
        leftPanView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(15)
        }
        rightPanView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalTo(self)
            make.width.equalTo(15)
        }
        coverView.snp.makeConstraints { (make) in
            make.left.equalTo(self.leftPanView.snp.right)
            make.right.equalTo(self.rightPanView.snp.left)
            make.top.bottom.equalTo(self)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        model?.start = x
        model?.width = width
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if leftPanView.frame.contains(point) {
            return leftPanView
        } else if rightPanView.frame.contains(point) {
            return rightPanView
        }
        return super.hitTest(point, with: event)
    }
    
    public func update(_ model: EditOperationCellModel) {
        self.model = model
    }
    
    public func showOperationView() {
        isSelected = true
        UIView.animate(withDuration: 0.25, animations: {
            self.leftPanView.alpha = 1
            self.rightPanView.alpha = 1
            self.coverView.alpha = 1
        })
    }
    
    public func hiddenOperationView() {
        isSelected = false
        UIView.animate(withDuration: 0.25, animations: {
            self.leftPanView.alpha = 0
            self.rightPanView.alpha = 0
            self.coverView.alpha = 0
        })
    }
    
    public func startValue(for duration: Double) -> Double {
        guard let superView = superview else { return 0 }
        guard let model = model else { return 0 }
        return Double(model.start) / Double(superView.width) * duration
    }
    
    public func endValue(for duration: Double) -> Double {
        guard let superView = superview else { return 0 }
        guard let model = model else { return 0 }
        return Double(model.start + model.width) / Double(superView.width) * duration
    }
    
    //MARK: Action
    
    @objc
    private func handleLeftPan(_ gesture: UIPanGestureRecognizer) {
        handleLeftPanClosure?(gesture)
    }
    
    @objc
    private func handleRightPan(_ gesture: UIPanGestureRecognizer) {
        handleRightPanClosure?(gesture)
    }
    
    @objc
    private func handleTap(_ tap: UITapGestureRecognizer) {
        if isSelected {
            hiddenOperationView()
        } else {
            showOperationView()
        }
        selectedClosure?(isSelected)
    }
    
    //MARK: Getter
    
    public lazy var leftPanView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        view.alpha = 0
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleLeftPan(_:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    
    public lazy var rightPanView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        view.alpha = 0
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleRightPan(_:)))
        view.addGestureRecognizer(pan)
        return view
    }()
    
    public lazy var coverView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
}
