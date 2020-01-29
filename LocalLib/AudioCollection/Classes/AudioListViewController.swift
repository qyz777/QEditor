//
//  AudioListViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/25.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import MediaPlayer
import TableViewAdapter
import AVFoundation
import SnapKit

class AudioListViewController: UIViewController {
    
    public var selectedClosure: ((_ model: AudioFileModel) -> Void)?
    
    private var cellModels: [AudioFileCellModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let bundle = Bundle(for: AudioListViewController.self)
        let bundleUrl = bundle.url(forResource: "AudioCollection", withExtension: "bundle")
        let closeItem = UIBarButtonItem(image: UIImage(named: "audio_back", in: Bundle(url: bundleUrl!), compatibleWith: nil), style: .plain, target: self, action: #selector(didClickCloseButton))
        closeItem.tintColor = .white
        navigationItem.leftBarButtonItem = closeItem
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    func update(_ models: [AudioFileModel]) {
        cellModels = models.map({ (model) -> AudioFileCellModel in
            AudioFileCellModel(with: model)
        })
        adapter.cellModels = cellModels
        adapter.reloadData()
    }
    
    @objc
    func didClickCloseButton() {
        navigationController?.popViewController(animated: true)
    }
    
    lazy var adapter: TableViewAdapter = {
        let adapter = TableViewAdapter(tableView: tableView, bundleName: "AudioCollection")
        adapter.adapterDelegate = self
        return adapter
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        return view
    }()

}

extension AudioListViewController: TableViewAdapterDelegate {
    
    func tableViewCell(_ cell: UITableViewCell, didDequeueRowAt indexPath: IndexPath) {
        if let cell = cell as? AudioFileCell {
            cell.clickClosure = { [unowned self] in
                self.selectedClosure?(self.cellModels[indexPath.row].model!)
            }
        }
    }
    
}
