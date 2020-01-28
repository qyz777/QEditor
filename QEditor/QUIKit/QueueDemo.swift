//
//  QueueDemo.swift
//  QEditor
//
//  Created by Q YiZhong on 2020/1/28.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import libkern

//public struct DispatchContext {
//    let name: String
//    let queues: [DispatchQueue]
//    var counter: Int32 = 0
//    let queueCount: Int
//    
//    public init(name: String, queueCount: Int, qos: DispatchQoS) {
//        self.name = name
//        self.queueCount = queueCount
//        var queues: [DispatchQueue] = []
//        for _ in 0..<queueCount {
//            let queue = DispatchQueue(label: name, qos: qos, attributes: [], autoreleaseFrequency: .inherit, target: nil)
//            queues.append(queue)
//        }
//        self.queues = queues
//    }
//    
//    mutating func getQueue() -> DispatchQueue {
//        let newCounter = OSAtomicIncrement32(&counter)
//        let queue = queues[Int(newCounter) % queueCount]
//        return queue
//    }
//    
//}
//
//public class DispatchQueuePool {
//    
//    private var context: DispatchContext
//    
//    init(context: DispatchContext) {
//        self.context = context
//    }
//    
//    init(name: String, queueCount: Int, qos: DispatchQoS) {
//        context = DispatchContext(name: name, queueCount: queueCount, qos: qos)
//    }
//    
//    public var queue: DispatchQueue {
//        return context.getQueue()
//    }
//    
//}


