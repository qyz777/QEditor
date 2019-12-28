//
//  PlayerProtocol.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/13.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

protocol PlayerProtocol {
    
    func play()
    
    func stop()
    
    func pause()
    
    func seek(to time: Int64)
    
}
