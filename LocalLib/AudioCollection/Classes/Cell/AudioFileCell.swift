//
//  AudioFileCell.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/25.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import TableViewAdapter
import MediaPlayer
import SnapKit

class AudioFileCell: UITableViewCell, BaseTableViewCell {
    
    public var clickClosure: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupSubviews() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(singerLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(useButton)
        
        coverImageView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 90, height: 90))
            make.left.equalTo(SCREEN_PADDING_X)
            make.centerY.equalTo(self.contentView)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.coverImageView.snp.right).offset(SCREEN_PADDING_X)
            make.top.equalTo(self.coverImageView)
            make.right.equalTo(self.useButton.snp.left).offset(-SCREEN_PADDING_X)
        }
        
        singerLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nameLabel)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(5)
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.singerLabel)
            make.bottom.equalTo(self.coverImageView)
        }
        
        useButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.contentView).offset(-SCREEN_PADDING_X)
            make.centerY.equalTo(self.contentView)
            make.width.equalTo(40)
        }
    }

    func updateCell(with cellModel: BaseTableViewCellModel) {
        guard let cellModel = cellModel as? AudioFileCellModel else {
            return
        }
        guard let model = cellModel.model else {
            return
        }
        coverImageView.image = model.item.artwork?.image(at: CGSize(width: 90, height: 90))
        nameLabel.text = model.item.title
        singerLabel.text = model.item.artist
        let duration = model.item.playbackDuration
        let time: String
        if Int(duration) % 60 < 10 {
            time = "\(Int(duration) / 60) : 0\(Int(duration) % 60)"
        } else {
            time = "\(Int(duration) / 60) : \(Int(duration) % 60)"
        }
        timeLabel.text = time
    }
    
    @objc
    func useButtonDidClick() {
        clickClosure?()
    }
    
    lazy var coverImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        view.numberOfLines = 0
        return view
    }()
    
    lazy var singerLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.hex(0xEEEEEE)
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return view
    }()
    
    lazy var useButton: UIButton = {
        let view = UIButton(type: .custom)
        view.layer.cornerRadius = 4
        view.setTitle("使用", for: .normal)
        view.titleLabel?.textColor = UIColor.hex(0xEEEEEE)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        view.backgroundColor = UIColor.hex(0xFA3E54)
        view.addTarget(self, action: #selector(useButtonDidClick), for: .touchUpInside)
        return view
    }()

}

extension UIColor {
    
    static func hex(_ hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
                       green: CGFloat((hex & 0xFF00) >> 8) / 255.0,
                       blue: CGFloat(hex & 0xFF) / 255.0,
                       alpha: 1.0)
    }
    
}
