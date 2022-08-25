import Foundation

/**
 Will be redundent when we move to Combine
 */

public func sequencedResultRequests<Out, Err: Error>(
    notifyQueue: DispatchQueue = .main,
    _ requests: [AsyncRequest<Result<Out, Err>>],
    _ completion: @escaping CompletionHandler<Result<[Out], Err>>)
{
    var requests: [AsyncRequest<Result<Out, Err>>] = requests.reversed()
    var results = [Out]()
    func run() {
        guard let next = requests.popLast() else {
            notifyQueue.async {
                completion(.success(results))
            }
            return
        }
        next { $0
            .on(notifyQueue) { $0
                .ifFailure {
                    completion(.failure($0))
                }
                .ifSuccess {
                    results.append($0)
                    run()
                }
            }
        }
    }
    run()
}
