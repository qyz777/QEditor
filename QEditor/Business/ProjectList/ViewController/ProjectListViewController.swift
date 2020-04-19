//
//  ProjectListViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/4/11.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import TableViewAdapter
import DeviceKit

let JSON_STASH_PATH = String.qe.documentPath() + "/" + "Project/"

class ProjectListViewController: UIViewController {
    
    var adapter: TableViewAdapter!
    
    var dataArray: [ProjectCellModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter = TableViewAdapter(tableView: tableView)
        adapter.tableViewDelegate = self
        adapter.tableViewDataSource = self
        setupSubviews()
        
        loadJSON()
    }
    
    private func setupSubviews() {
        title = "草稿"
        view.backgroundColor = .black
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalTo(self.view)
            make.top.equalTo(self.view).offset(UIDevice.qe.isXSeries() ? 84 : 64)
        }
        let item = UIBarButtonItem(customView: addButton)
        navigationItem.rightBarButtonItem = item
    }
    
    private func loadJSON() {
        //1.检查文件夹是否存在，不存在创建
        checkDirectory()
        //2.遍历当前目录所有文件获得JSON
        dataArray.removeAll()
        var paths: [String] = []
        do {
            try paths = FileManager.default.contentsOfDirectory(atPath: JSON_STASH_PATH).map({ (path) -> String in
                return JSON_STASH_PATH + "/" + path
            })
        } catch {
            QELog(error)
            return
        }
        paths = paths.filter { (path) -> Bool in
            return path.hasSuffix(".json")
        }
        for path in paths {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let obj = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                guard let json = obj else { return }
                let config = try CompositionProjectConfig(json: json)
                let cm = ProjectCellModel(with: config)
                cm.path = path
                dataArray.append(cm)
            } catch {
                QELog(error)
            }
        }
        //3.刷新tableView
        adapter.cellModels = dataArray
        adapter.reloadData()
    }
    
    private func handleVideos(_ videos: [MediaVideoModel]) {
        let urls = videos.map { (model) -> URL in
            return model.url!
        }
        let vc = EditViewController.buildView(with: urls)
        vc.delegate = self
        let nav = NavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    private func checkDirectory() {
        let point = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        point.initialize(to: ObjCBool(true))
        if !FileManager.default.fileExists(atPath: JSON_STASH_PATH, isDirectory: point) {
            do {
                try FileManager.default.createDirectory(atPath: JSON_STASH_PATH, withIntermediateDirectories: true, attributes: nil)
            } catch {
                QELog(error)
                return
            }
        }
        point.deinitialize(count: 1)
        point.deallocate()
    }
    
    @objc
    private func addButtonDidClick() {
        let vc = MediaViewController.buildView()
        vc.completion = { [unowned self] (_ videos: [MediaVideoModel], _ photos: [MediaImageModel]) in
            if videos.count > 0 {
                self.handleVideos(videos)
            }
        }
        let nav = NavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.tableFooterView = UIView()
        return view
    }()
    
    lazy var addButton: UIButton = {
        let view = UIButton(type: .custom)
        view.setImage(UIImage(named: "project_add"), for: .normal)
        view.addTarget(self, action: #selector(addButtonDidClick), for: .touchUpInside)
        return view
    }()

}

extension ProjectListViewController: EditViewControllerDelegate {
    
    func edit(viewController: EditViewController, stash config: CompositionProjectConfig) {
        //1.检查文件夹是否存在
        checkDirectory()
        //2.判断是否需要更新
        let json = config.toJSON()
        var i = 0
        var isUpdate = false
        for data in dataArray {
            guard let c = data.config else { continue }
            if c.id == config.id {
                isUpdate = true
                break
            }
            i += 1
        }
        //3.本地持久化
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            let path = JSON_STASH_PATH + String.qe.timestamp() + ".json"
            try data.write(to: URL(fileURLWithPath: path))
            //4.刷新列表
            if isUpdate {
                let oldCm = dataArray[i]
                try FileManager.default.removeItem(atPath: oldCm.path)
                let cm = ProjectCellModel(with: config)
                cm.path = path
                dataArray[i] = cm
                adapter.cellModels = dataArray
                adapter.reloadData()
            } else {
                loadJSON()
            }
        } catch {
            QELog(error)
            MessageBanner.error(content: "草稿保存失败")
            return
        }
    }
    
}

extension ProjectListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        do {
            try FileManager.default.removeItem(atPath: dataArray[indexPath.row].path)
        } catch {
            QELog(error)
        }
        dataArray.remove(at: indexPath.row)
        adapter.deleteCell(at: indexPath.row, with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let config = dataArray[indexPath.row].config else { return }
        let vc = EditViewController.buildView(with: config)
        vc.delegate = self
        let nav = NavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    
}
