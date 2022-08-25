import Foundation

/**
 Will be redundent when we move to Combine
 */

public func parallelResultRequests<Out, Err: Error>(
    notifyQueue: DispatchQueue = .main,
    _ requests: [AsyncRequest<Result<Out, Err>>],
    _ completion: @escaping CompletionHandler<Result<[Out], Err>>)
{
    parallelRequests(notifyQueue: notifyQueue, requests) {
        do {
            completion(
                .success(try $0.map { try $0.get() })
            )
        } catch {
            guard let error = error as? Err else {
                return
            }
            completion(.failure(error))
        }
    }
}

public func parallelResultRequests<Out1, Out2, Err: Error>(
    notifyQueue: DispatchQueue = .main,
    _ ar1: @escaping AsyncRequest<Result<Out1, Err>>,
    _ ar2: @escaping AsyncRequest<Result<Out2, Err>>,
    _ completion: @escaping CompletionHandler<Result<(Out1, Out2), Err>>)
{
    parallelRequests(notifyQueue: notifyQueue, ar1, ar2) {
        do {
            completion(
                .success((
                    try $0.0.get(),
                    try $0.1.get()
                ))
            )
        } catch {
            guard let error = error as? Err else {
                return
            }
            completion(.failure(error))
        }
    }
}

public func parallelResultRequests<Out1, Out2, Out3, Err: Error>(
    notifyQueue: DispatchQueue = .main,
    _ ar1: @escaping AsyncRequest<Result<Out1, Err>>,
    _ ar2: @escaping AsyncRequest<Result<Out2, Err>>,
    _ ar3: @escaping AsyncRequest<Result<Out3, Err>>,
    _ completion: @escaping CompletionHandler<Result<(Out1, Out2, Out3), Err>>)
{
    parallelRequests(notifyQueue: notifyQueue, ar1, ar2, ar3) {
        do {
            completion(
                .success((
                    try $0.0.get(),
                    try $0.1.get(),
                    try $0.2.get()
                ))
            )
        } catch {
            guard let error = error as? Err else {
                return
            }
            completion(.failure(error))
        }
    }
}
