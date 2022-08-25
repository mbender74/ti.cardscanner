import Foundation

public func weakClosure<WeakValue: AnyObject>(_ weakValue: WeakValue, on asyncQueue: DispatchQueue? = nil, _ closure: @escaping (WeakValue) -> Void) -> () -> Void { { [weak weakValue] in
        asyncQueue.asyncWithNowFallback {
            guard let value = weakValue else { return }
            closure(value)
        }
    }
}
public func weakClosure<WeakValue: AnyObject, T1>(_ weakValue: WeakValue, on asyncQueue: DispatchQueue? = nil, _ closure: @escaping (WeakValue, T1) -> Void) -> (T1) -> Void { { [weak weakValue] t1 in
        asyncQueue.asyncWithNowFallback {
            guard let value = weakValue else { return }
            closure(value, t1)
        }
    }
}
public func weakClosure<WeakValue: AnyObject, T1, T2>(_ weakValue: WeakValue, on asyncQueue: DispatchQueue? = nil, _ closure: @escaping (WeakValue, T1, T2) -> Void) -> (T1, T2) -> Void { { [weak weakValue] t1, t2 in
        asyncQueue.asyncWithNowFallback {
            guard let value = weakValue else { return }
            closure(value, t1, t2)
        }
    }
}
public func weakClosure<WeakValue: AnyObject, T1, T2, T3>(_ weakValue: WeakValue, on asyncQueue: DispatchQueue? = nil, _ closure: @escaping (WeakValue, T1, T2, T3) -> Void) -> (T1, T2, T3) -> Void { { [weak weakValue] t1, t2, t3 in
        asyncQueue.asyncWithNowFallback {
            guard let value = weakValue else { return }
            closure(value, t1, t2, t3)
        }
    }
}
public func weakClosure<WeakValue: AnyObject, T1, T2, T3, T4>(_ weakValue: WeakValue, on asyncQueue: DispatchQueue? = nil, _ closure: @escaping (WeakValue, T1, T2, T3, T4) -> Void) -> (T1, T2, T3, T4) -> Void { { [weak weakValue] t1, t2, t3, t4 in
        asyncQueue.asyncWithNowFallback {
            guard let value = weakValue else { return }
            closure(value, t1, t2, t3, t4)
        }
    }
}

public extension DispatchQueue {
    func asyncWeakClosure<WeakValue: AnyObject>(_ weakValue: WeakValue, _ closure: @escaping (WeakValue) -> Void) {
        async(execute: weakClosure(weakValue, closure))
    }
    func asyncWeakClosure<WeakValue: AnyObject>(_ weakValue: WeakValue, afterDeadline deadline: DispatchTime, _ closure: @escaping (WeakValue) -> Void) {
        asyncAfter(deadline: deadline, execute: weakClosure(weakValue, closure))
    }
}

private extension Optional where Wrapped: DispatchQueue {
    // Please dont make public unless the name is changed to something that does not suck
    func asyncWithNowFallback(execute work: @escaping () -> Void) {
        if let some = self {
            some.async(execute: work)
        } else {
            work()
        }
    }
}
