//
//  AudioCollectionViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/26.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import SnapKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_PADDING_X: CGFloat = 15
let AUDIO_COLLECTION_SPACING: CGFloat = 30
let AUDIO_COLLECTION_WIDTH: CGFloat = (SCREEN_WIDTH - SCREEN_PADDING_X * 2 - AUDIO_COLLECTION_SPACING) / 2

public class AudioCollectionViewController: UIViewController {
    
    public var selectedClosure: ((_ model: AudioFileModel) -> Void)?
    
    private let service = AudioDataService()
    
    private var collections: [AudioCollectionModel] = []

    public override func viewDidLoad() {
        super.viewDidLoad()
        title = "媒体资料库"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        let bundle = Bundle(for: AudioCollectionViewController.self)
        let bundleUrl = bundle.url(forResource: "AudioCollection", withExtension: "bundle")
        let closeItem = UIBarButtonItem(image: UIImage(named: "audio_close", in: Bundle(url: bundleUrl!), compatibleWith: nil), style: .plain, target: self, action: #selector(didClickCloseButton))
        closeItem.tintColor = .white
        navigationItem.leftBarButtonItem = closeItem
        collections = service.fetchAudioCollections()
        requestAuthorizationForMediaLibrary()
        collectionView.reloadData()
    }
    
    @objc
    func didClickCloseButton() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func requestAuthorizationForMediaLibrary() {
        let status = MPMediaLibrary.authorizationStatus()
        if status != .authorized {
            let alert = UIAlertController(title: "提示", message: "您还未开媒体资料库访问权限", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "去开启", style: .default) { (action) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:]) { [unowned self] (completion) in
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "取消", style: .cancel) { [unowned self] (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: AUDIO_COLLECTION_WIDTH, height: AUDIO_COLLECTION_WIDTH)
        layout.minimumInteritemSpacing = AUDIO_COLLECTION_SPACING
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.delegate = self
        view.dataSource = self
        view.register(AudioCollectionViewCell.self, forCellWithReuseIdentifier: "AudioCollectionViewCell")
        view.contentInset = .init(top: 15, left: SCREEN_PADDING_X, bottom: 15, right: SCREEN_PADDING_X)
        return view
    }()

}

extension AudioCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collections.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCollectionViewCell", for: indexPath) as! AudioCollectionViewCell
        cell.imageView.image = collections[indexPath.item].thumbnail
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = AudioListViewController()
        vc.selectedClosure = { [unowned self] (model) in
            self.navigationController?.dismiss(animated: true, completion: {
                self.selectedClosure?(model)
            })
        }
        vc.update(collections[indexPath.item].files)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

fileprivate class AudioCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
}
