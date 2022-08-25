//
//  WriteSafe.swift
//  GymsharkCore
//
//  Created by Dominic Campbell on 23/10/2020.
//

import Foundation

public class WriteSafe {
    private var semaphore = DispatchSemaphore(value: 1)
    public init() {}
    public func perform<T>(_ action: () -> T) -> T {
        semaphore.wait()
        let result = action()
        semaphore.signal()
        return result
    }
}
