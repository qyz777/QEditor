//
//  EditToolChooseBoxView.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/11/2.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit

fileprivate let CHOOSE_BOX_MIN_WIDTH: CGFloat = 60

class EditToolChooseBoxView: UIView {
    
    private var maxWidth: CGFloat = 0
    
    private var currentWidth: CGFloat = 0
    
    private var beginLeft: CGFloat = 0
    
    public var initLeft: CGFloat = 0

    init(with maxWidth: CGFloat) {
        super.init(frame: .init(x: 0, y: 0, width: CHOOSE_BOX_MIN_WIDTH, height: EDIT_THUMB_CELL_SIZE))
        self.maxWidth = maxWidth
        currentWidth = maxWidth
        setupSubviews()
        
        let leftPan = UIPanGestureRecognizer(target: self, action: #selector(handleLeftPan(_:)))
        let rightPan = UIPanGestureRecognizer(target: self, action: #selector(handleRightPan(_:)))
        leftPanView.addGestureRecognizer(leftPan)
        rightPanView.addGestureRecognizer(rightPan)
    }
    
    private func setupSubviews() {
        backgroundColor = .clear
        addSubview(leftPanView)
        addSubview(rightPanView)
        addSubview(topLineView)
        addSubview(bottomLineView)
        
        leftPanView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(self)
            make.width.equalTo(25)
        }
        
        rightPanView.snp.makeConstraints { (make) in
            make.right.bottom.top.equalTo(self)
            make.width.equalTo(25)
        }
        
        topLineView.snp.makeConstraints { (make) in
            make.left.equalTo(self.leftPanView.snp.right)
            make.right.equalTo(self.rightPanView.snp.left)
            make.top.equalTo(self)
            make.height.equalTo(1)
        }
        
        bottomLineView.snp.makeConstraints { (make) in
            make.left.equalTo(self.leftPanView.snp.right)
            make.right.equalTo(self.rightPanView.snp.left)
            make.bottom.equalTo(self)
            make.height.equalTo(1)
        }
    }
    
    @objc
    func handleLeftPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginLeft = qe.left
        case .changed:
            let point = gesture.translation(in: superview)
            let targetWidth = currentWidth - point.x
            let targetLeft = beginLeft + point.x
            guard targetWidth >= CHOOSE_BOX_MIN_WIDTH || targetWidth <= maxWidth else {
                return
            }
            guard targetLeft >= initLeft else {
                return
            }
            qe.width = targetWidth
            qe.left = targetLeft
        default:
            beginLeft = qe.left
            currentWidth = qe.width
            break
        }
    }
    
    @objc
    func handleRightPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            beginLeft = qe.left
        case .changed:
            let point = gesture.translation(in: superview)
            let targetWidth = currentWidth + point.x
            guard targetWidth >= CHOOSE_BOX_MIN_WIDTH || targetWidth <= maxWidth else {
                return
            }
            guard beginLeft + targetWidth <= initLeft + maxWidth else {
                return
            }
            qe.width = targetWidth
        default:
            currentWidth = qe.width
            break
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var topLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        return view
    }()
    
    lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        return view
    }()
    
    lazy var leftPanView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        let v = UIView()
        v.backgroundColor = .lightGray
        v.layer.cornerRadius = 1
        view.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.height.equalTo(MEDIA_ITEM_SIZE / 4)
            make.width.equalTo(2)
        }
        return view
    }()
    
    lazy var rightPanView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        view.layer.cornerRadius = 4
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        let v = UIView()
        v.backgroundColor = .lightGray
        v.layer.cornerRadius = 1
        view.addSubview(v)
        v.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.height.equalTo(MEDIA_ITEM_SIZE / 4)
            make.width.equalTo(2)
        }
        return view
    }()

}
