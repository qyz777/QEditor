#TableViewAdapter

## 简介

轻量级TableView的封装库，通过数据驱动来刷新view

## 使用说明

1. cellModel实现`BaseTableViewCellModel`协议用来生成cell

   ```swift
   //cell的高度
   func cellHeight() -> CGFloat
   
   //cell的类名
   func cellClassName() -> String
   
   //通过实现BaseModel协议的对象初始化
   init(with model: BaseModel?)
   ```

2. 数据源Model实现`BaseModel`协议用来生成cellModel

3. 通过数据刷新列表

   在不使用section的情况下只需给`adapter`赋值`cellModels`并调用`reloadData()`方法进行刷新

   

### TableView的代理

tableView原先的代理可以通过`adapter`的`tableViewDelegate`来实现