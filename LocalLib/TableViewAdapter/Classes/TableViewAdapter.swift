//
//  TableViewAdapter.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/1/26.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

public protocol TableViewAdapterDelegate: class {
    
    /// cell被复用时调用此代理
    /// - Parameters:
    ///   - cell: cell
    ///   - indexPath: indexPath
    func tableViewCell(_ cell: UITableViewCell, didDequeueRowAt indexPath: IndexPath)
    
}

public class TableViewAdapter: NSObject {
    
    /// 使用section时必须置位true！
    public var isNeedSection = false
    
    /// 使用section时赋值的数据源
    public var sectionCellModelsArray: [[BaseTableViewCellModel]] = []
    
    /// 仅使用row时赋值的数据源
    public var cellModels: [BaseTableViewCellModel] = []
    
    public weak var adapterDelegate: TableViewAdapterDelegate?
    
    private weak var tableView: UITableView?
    
    private var bundleName: String?
    
    private var _delegateProxy: ProtocolProxy?
    private var _dataSourceProxy: ProtocolProxy?
    
    private weak var _tableViewDelegate: UITableViewDelegate?
    public weak var tableViewDelegate: UITableViewDelegate? {
        set {
            if !(_tableViewDelegate?.isEqual(newValue) ?? false) {
                _tableViewDelegate = newValue
                updateDelegate()
            }
        }
        get {
            return _tableViewDelegate!
        }
    }
    
    private weak var _tableViewDataSource: UITableViewDataSource?
    public weak var tableViewDataSource: UITableViewDataSource? {
        set {
            if !(_tableViewDataSource?.isEqual(newValue) ?? false) {
                _tableViewDataSource = newValue
                updateDataSource()
            }
        }
        get {
            return _tableViewDataSource!
        }
    }
    
    /// 插入cell，索引不对则无任何效果
    /// - Parameter cellModel: cellModel
    /// - Parameter row: row索引
    /// - Parameter section: section索引
    /// - Parameter animation: 动画类型
    public func insertCell(with cellModel: BaseTableViewCellModel, at row: Int, in section: Int = 0, with animation: UITableView.RowAnimation) {
        insertCells(with: [cellModel], at: row, in: section, with: animation)
    }
    
    /// 插入cell，索引不对则无任何效果
    /// - Parameter cellModels: cellModel
    /// - Parameter row: row索引
    /// - Parameter section: section索引
    /// - Parameter animation: 动画类型
    public func insertCells(with cellModels: [BaseTableViewCellModel], at row: Int, in section: Int = 0, with animation: UITableView.RowAnimation) {
        if isNeedSection {
            guard section >= 0 && section < sectionCellModelsArray.count else {
                return
            }
            var rowDataArray = sectionCellModelsArray[section]
            guard row >= 0 else {
                return
            }
            rowDataArray.insert(contentsOf: cellModels, at: row)
            sectionCellModelsArray[section] = rowDataArray
            var indexPaths: [IndexPath] = []
            for i in 0..<cellModels.count {
                indexPaths.append(IndexPath(row: i + row, section: section))
            }
            tableView?.insertRows(at: indexPaths, with: animation)
        } else {
            guard row >= 0 && row <= cellModels.count else {
                return
            }
            self.cellModels.insert(contentsOf: cellModels, at: row)
            var indexPaths: [IndexPath] = []
            for i in 0..<cellModels.count {
                indexPaths.append(IndexPath(row: i + row, section: 0))
            }
            tableView?.insertRows(at: indexPaths, with: animation)
        }
    }
    
    /// 删除cell，索引不对则无任何效果
    /// - Parameter row: row索引
    /// - Parameter length: 长度
    /// - Parameter section: section索引
    /// - Parameter animation: 动画类型
    public func deleteCell(at row: Int, in section: Int = 0, with animation: UITableView.RowAnimation) {
        deleteCells(at: row, with: 1, in: section, with: animation)
    }
    
    /// 删除cell，索引不对则无任何效果
    /// - Parameter row: row索引
    /// - Parameter length: 长度
    /// - Parameter section: section索引
    /// - Parameter animation: 动画类型
    public func deleteCells(at row: Int, with length: Int, in section: Int = 0, with animation: UITableView.RowAnimation) {
        if isNeedSection {
            guard section >= 0 && section < sectionCellModelsArray.count else {
                return
            }
            var rowDataArray = sectionCellModelsArray[section]
            guard row >= 0 && row + length <= rowDataArray.count else {
                return
            }
            rowDataArray.removeSubrange(row..<row + length)
            sectionCellModelsArray[section] = rowDataArray
            var indexPaths: [IndexPath] = []
            for i in row..<row + length {
                indexPaths.append(IndexPath(row: i, section: section))
            }
            tableView?.deleteRows(at: indexPaths, with: animation)
        } else {
            guard row >= 0 && row + length <= cellModels.count else {
                return
            }
            cellModels.removeSubrange(row..<row + length)
            var indexPaths: [IndexPath] = []
            for i in row..<row + length {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            tableView?.deleteRows(at: indexPaths, with: animation)
        }
    }
    
    private func updateDelegate() {
        tableView?.delegate = nil
        if _tableViewDelegate != nil {
            _delegateProxy = ProtocolProxy(with: _tableViewDelegate, for: self)
        }
        tableView?.delegate = _delegateProxy == nil ? self : _delegateProxy
    }
    
    private func updateDataSource() {
        tableView?.dataSource = nil
        if _tableViewDataSource != nil {
            _dataSourceProxy = ProtocolProxy(with: _tableViewDataSource, for: self)
        }
        tableView?.dataSource = _dataSourceProxy == nil ? self : _dataSourceProxy
    }
    
    /// 初始化方法
    /// - Parameters:
    ///   - tableView: adapter管理的tableView
    ///   - bundleName: adapter管理的cell所在bundle，此库被其他pod依赖时需要传入此参数
    required public init(tableView: UITableView, bundleName: String? = nil) {
        super.init()
        self.tableView = tableView
        self.tableView?.estimatedRowHeight = 0
        self.tableView?.estimatedSectionHeaderHeight = 0
        self.tableView?.estimatedSectionFooterHeight = 0
        self.bundleName = bundleName
        updateDataSource()
        updateDelegate()
    }
    
    public func reloadData() {
        tableView?.reloadData()
    }
    
}

extension TableViewAdapter: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return isNeedSection ? sectionCellModelsArray.count : 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isNeedSection ? sectionCellModelsArray[section].count : cellModels.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = isNeedSection ? sectionCellModelsArray[indexPath.section][indexPath.row] : cellModels[indexPath.row]
        var cell = tableView.dequeueReusableCell(withIdentifier: model.cellClassName())
        if cell == nil {
            //bugfix:此pod作为别的pod的依赖库时需要从bundleName处获取前缀
            let prefixName: String = bundleName != nil ? bundleName! : Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            let cellType = NSClassFromString(prefixName + "." + model.cellClassName()) as! UITableViewCell.Type
            cell = cellType.init(style: .default, reuseIdentifier: model.cellClassName())
        }
        adapterDelegate?.tableViewCell(cell!, didDequeueRowAt: indexPath)
        (cell as! BaseTableViewCell).updateCell(with: model)
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return isNeedSection ? sectionCellModelsArray[indexPath.section][indexPath.row].cellHeight() : cellModels[indexPath.row].cellHeight()
    }
    
}
