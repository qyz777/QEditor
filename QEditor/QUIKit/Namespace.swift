//
//  Namespace.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/12.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import Foundation

public class Namespace<Base> {
    public var base: Base
    init(_ base: Base) {
        self.base = base
    }
}

public protocol NamespaceProtocol {}
extension NSObject: NamespaceProtocol {}
extension String: NamespaceProtocol {}
extension Array: NamespaceProtocol {}
public extension NamespaceProtocol {
    var qe: Namespace<Self> {
        return Namespace<Self>(self)
    }
    static var qe: Namespace<Self>.Type {
        return Namespace<Self>.self
    }
}
