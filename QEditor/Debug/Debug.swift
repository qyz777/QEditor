//
//  Debug.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/27.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

func QELog<T>(_ message: T) {
    #if DEBUG
        print("\(message)")
    #endif
}
