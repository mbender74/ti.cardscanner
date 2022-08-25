import Foundation
/**
 Will be redundent when we move to Combine
 */

public func parallelRequests<Out>(
    notifyQueue: DispatchQueue = .main,
    _ requests: [AsyncRequest<Out>],
    _ completion: @escaping CompletionHandler<[Out]>)
{
    let group = DispatchGroup()
    var results = ThreadSafe(wrappedValue: [Out?](repeating: nil, count: requests.count))
    requests.enumerated().forEach { pair in
        group.enter()
        pair.element {
            results.wrappedValue[pair.offset] = $0
            group.leave()
        }
    }
    group.notify(queue: notifyQueue) {
        completion(results.wrappedValue.compactMap({ $0 }))
    }
}

public func parallelRequests<Out1, Out2>(
    notifyQueue: DispatchQueue = .main,
    _ ar1: @escaping AsyncRequest<Out1>,
    _ ar2: @escaping AsyncRequest<Out2>,
    _ completion: @escaping CompletionHandler<(Out1, Out2)>)
{
    let group = DispatchGroup()
    
    group.enter()
    var result1: Out1?
    ar1 {
        result1 = $0
        group.leave()
    }
    
    group.enter()
    var result2: Out2?
    ar2 {
        result2 = $0
        group.leave()
    }
    
    group.notify(queue: notifyQueue) {
        guard
            let out1 = result1,
            let out2 = result2
        else {
            return
        }
        completion((out1, out2))
    }
}

public func parallelRequests<Out1, Out2, Out3>(
    notifyQueue: DispatchQueue = .main,
    _ ar1: @escaping AsyncRequest<Out1>,
    _ ar2: @escaping AsyncRequest<Out2>,
    _ ar3: @escaping AsyncRequest<Out3>,
    _ completion: @escaping CompletionHandler<(Out1, Out2, Out3)>)
{
    let group = DispatchGroup()
    
    group.enter()
    var result1: Out1?
    ar1 {
        result1 = $0
        group.leave()
    }
    
    group.enter()
    var result2: Out2?
    ar2 {
        result2 = $0
        group.leave()
    }
    
    group.enter()
    var result3: Out3?
    ar3 {
        result3 = $0
        group.leave()
    }
    
    group.notify(queue: notifyQueue) {
        guard
            let out1 = result1,
            let out2 = result2,
            let out3 = result3
        else {
            return
        }
        completion((out1, out2, out3))
    }
}
