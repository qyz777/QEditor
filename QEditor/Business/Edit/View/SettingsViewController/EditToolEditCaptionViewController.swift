//
//  EditToolEditCaptionViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/3/9.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import EFColorPicker

fileprivate let OPTION_CELL_SIZE = (SCREEN_WIDTH - SCREEN_PADDING_X * 2 - 15 * 3) / 4

class EditToolEditCaptionViewController: EditToolBaseSettingsViewController {
    
    var presenter: EditCaptionViewOutput!
    
    var segment: CompositionCaptionSegment? {
        willSet {
            guard let s = newValue else { return }
            for i in 0..<fontCellModels.count {
                var m = fontCellModels[i]
                if m.fontName == s.fontName {
                    m.isSelected = true
                } else {
                    m.isSelected = false
                }
                fontCellModels[i] = m
            }
            for i in 0..<fontSizeCellModels.count {
                var m = fontSizeCellModels[i]
                if m.fontSize == s.fontSize {
                    m.isSelected = true
                } else {
                    m.isSelected = false
                }
                fontSizeCellModels[i] = m
            }
            colorButton.backgroundColor = s.textColor
        }
    }
    
    private var fontCellModels: [CaptioOptionCellModel] = [
        CaptioOptionCellModel(fontName: CompositionCaptionFontName.PingFangSC.regular.rawValue, fontSize: CompositionCaptionFontSize.small, text: CompositionCaptionFontName.PingFangSC.regular.rawValue),
        CaptioOptionCellModel(fontName: CompositionCaptionFontName.PingFangSC.medium.rawValue, fontSize: CompositionCaptionFontSize.small, text: CompositionCaptionFontName.PingFangSC.medium.rawValue),
        CaptioOptionCellModel(fontName: CompositionCaptionFontName.PingFangSC.semibold.rawValue, fontSize: CompositionCaptionFontSize.small, text: CompositionCaptionFontName.PingFangSC.semibold.rawValue),
        CaptioOptionCellModel(fontName: CompositionCaptionFontName.PingFangSC.light.rawValue, fontSize: CompositionCaptionFontSize.small, text: CompositionCaptionFontName.PingFangSC.light.rawValue)
    ]
    
    private var fontSizeCellModels: [CaptioOptionCellModel] = [
        CaptioOptionCellModel(fontName: "PingFangSC-Regular", fontSize: CompositionCaptionFontSize.small, text: "小"),
        CaptioOptionCellModel(fontName: "PingFangSC-Regular", fontSize: CompositionCaptionFontSize.normal, text: "标准"),
        CaptioOptionCellModel(fontName: "PingFangSC-Regular", fontSize: CompositionCaptionFontSize.large, text: "大"),
        CaptioOptionCellModel(fontName: "PingFangSC-Regular", fontSize: CompositionCaptionFontSize.superLarge, text: "超大")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setupEditCaptionView(self)
        okButton.isHidden = true
        view.addSubview(fontNameLabel)
        view.addSubview(fontNameView)
        view.addSubview(fontSizeLabel)
        view.addSubview(fontSizeView)
        view.addSubview(colorLabel)
        view.addSubview(colorButton)
        
        fontNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.topBar.snp.bottom)
            make.centerX.equalToSuperview()
        }
        fontNameView.snp.makeConstraints { (make) in
            make.top.equalTo(self.fontNameLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(OPTION_CELL_SIZE)
        }
        fontSizeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.fontNameView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        fontSizeView.snp.makeConstraints { (make) in
            make.top.equalTo(self.fontSizeLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(OPTION_CELL_SIZE)
        }
        colorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.fontSizeView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        colorButton.snp.makeConstraints { (make) in
            make.top.equalTo(self.colorLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 30))
        }
        
        fontNameView.cellModels = fontCellModels
        fontSizeView.cellModels = fontSizeCellModels
        fontNameView.reloadData()
        fontSizeView.reloadData()
    }
    
    @objc
    private func colorButtonTouchUpInside() {
        let vc = EFColorSelectionViewController()
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.permittedArrowDirections = .down
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.sourceView = colorButton
        vc.popoverPresentationController?.sourceRect = colorButton.bounds
        vc.preferredContentSize = CGSize(width: SCREEN_WIDTH - SCREEN_PADDING_X * 2, height: 250)

        vc.delegate = self
        vc.color = colorButton.backgroundColor ?? .white
        vc.setMode(mode: .rgb)

        UIViewController.qe.current()?.present(vc, animated: true, completion: nil)
    }
    
    private lazy var fontNameView: EditToolCaptioOptionCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: OPTION_CELL_SIZE, height: OPTION_CELL_SIZE)
        layout.minimumLineSpacing = 15
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: SCREEN_PADDING_X, bottom: 0, right: SCREEN_PADDING_X)
        let view = EditToolCaptioOptionCollectionView(frame: .zero, collectionViewLayout: layout)
        view.selectedClosure = { [unowned self, view] (model) in
            for i in 0..<self.fontCellModels.count {
                var m = self.fontCellModels[i]
                if m.fontName == model.fontName {
                    m.isSelected = true
                } else {
                    m.isSelected = false
                }
                self.fontCellModels[i] = m
            }
            view.cellModels = self.fontCellModels
            view.reloadData()
            guard let s = self.segment else { return }
            s.fontName = model.fontName
            self.presenter.updateCaption(segment: s)
        }
        return view
    }()
    
    private lazy var fontSizeView: EditToolCaptioOptionCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: OPTION_CELL_SIZE, height: OPTION_CELL_SIZE)
        layout.minimumLineSpacing = 15
        layout.scrollDirection = .horizontal
        layout.sectionInset = .init(top: 0, left: SCREEN_PADDING_X, bottom: 0, right: SCREEN_PADDING_X)
        let view = EditToolCaptioOptionCollectionView(frame: .zero, collectionViewLayout: layout)
        view.selectedClosure = { [unowned self, view] (model) in
            for i in 0..<self.fontSizeCellModels.count {
                var m = self.fontSizeCellModels[i]
                if m.fontSize == model.fontSize {
                    m.isSelected = true
                } else {
                    m.isSelected = false
                }
                self.fontSizeCellModels[i] = m
            }
            view.cellModels = self.fontSizeCellModels
            view.reloadData()
            guard let s = self.segment else { return }
            s.fontSize = model.fontSize
            self.presenter.updateCaption(segment: s)
        }
        return view
    }()
    
    private lazy var fontNameLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "字体"
        return view
    }()
    
    private lazy var fontSizeLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "字号"
        return view
    }()
    
    private lazy var colorLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 13)
        view.textColor = UIColor.qe.hex(0xEEEEEE)
        view.text = "文字颜色"
        return view
    }()
    
    private lazy var colorButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.qe.hex(0xEEEEEE)
        view.addTarget(self, action: #selector(colorButtonTouchUpInside), for: .touchUpInside)
        return view
    }()

}

extension EditToolEditCaptionViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        guard let s = segment else { return }
        s.textColor = colorButton.backgroundColor ?? UIColor.qe.hex(0xEEEEEE)
        presenter.updateCaption(segment: s)
    }
    
}

extension EditToolEditCaptionViewController: EFColorSelectionViewControllerDelegate {
    
    func colorViewController(_ colorViewCntroller: EFColorSelectionViewController, didChangeColor color: UIColor) {
        colorButton.backgroundColor = color
    }
    
}

extension EditToolEditCaptionViewController: EditCaptionViewInput {}

//MARK: EditToolCaptioOptionCollectionView

struct CaptioOptionCellModel {
    let fontName: String
    let fontSize: CompositionCaptionFontSize
    let text: String
    var isSelected: Bool = false
}

fileprivate class EditToolCaptioOptionCollectionView: UICollectionView {
    
    var cellModels: [CaptioOptionCellModel] = []
    
    var selectedClosure: ((_ model: CaptioOptionCellModel) -> Void)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        register(cellWithClass: EditToolCaptioOptionCell.self)
        delegate = self
        dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension EditToolCaptioOptionCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: EditToolCaptioOptionCell.self, for: indexPath)
        cell.update(cellModels[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedClosure?(cellModels[indexPath.item])
    }
    
}

//MARK: EditToolCaptioOptionCell

fileprivate class EditToolCaptioOptionCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 2
        layer.borderColor = UIColor.qe.hex(0xFA3E54).cgColor
        layer.borderWidth = 1
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        
        containerView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: frame.size.width - 5, height: frame.size.height - 5))
            make.center.equalTo(self.contentView)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.containerView)
            make.left.equalToSuperview().offset(2)
            make.right.equalToSuperview().offset(-2)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func update(_ model: CaptioOptionCellModel) {
        titleLabel.font = UIFont(name: model.fontName, size: model.fontSize.size())
        titleLabel.text = model.text
        if model.isSelected {
            layer.borderWidth = 1
        } else {
            layer.borderWidth = 0
        }
    }
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.numberOfLines = 0
        view.textAlignment = .center
        return view
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.backgroundColor = UIColor.qe.hex(0x222222)
        return view
    }()
    
}
