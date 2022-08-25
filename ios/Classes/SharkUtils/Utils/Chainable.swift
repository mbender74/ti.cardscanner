//
//  Chainable.swift
//  
//
//  Created by Lee Burrows on 20/04/2021.
//

import Foundation

public protocol Chainable {}

public extension Chainable {
    
        @discardableResult func with(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }

    @discardableResult func mutatedWith(_ block: (inout Self) -> Void) -> Self {
        var value = self
        block(&value)
        return value
    }
}

extension NSObject: Chainable {}
