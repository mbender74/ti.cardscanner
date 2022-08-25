import Foundation

/**
 Will be redundent when we move to Combine
 */

public typealias CompletionHandler<Out> = (Out) -> Void
public typealias AsyncRequest<Out> = (@escaping CompletionHandler<Out>) -> Void

public func mapAsyncRequests<In, Out>(_ request: @escaping AsyncRequest<In>, map: @escaping (In) -> Out) -> AsyncRequest<Out> {
    { callback in
        request { result in
            callback(map(result))
        }
    }
}
