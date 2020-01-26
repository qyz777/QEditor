//
//  TableViewDataSourceProxy.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/2/20.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class TableViewDataSourceProxy: BaseProxy, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell.init(style: .default, reuseIdentifier: "cell")
    }
    

}
