import Foundation

/**
 Will be redundent when we move to Combine
 */

public func eraseParameters<P1, Out>(
    _ p1: P1,
    _ function: @escaping (P1, @escaping CompletionHandler<Out>) -> Void) -> AsyncRequest<Out>
{
    { function(p1, $0) }
}

public func eraseParameters<P1, P2, Out>(
    _ p1: P1,
    _ p2: P2,
    _ function: @escaping (P1, P2, @escaping CompletionHandler<Out>) -> Void) -> AsyncRequest<Out>
{
    { function(p1, p2, $0) }
}

public func eraseParameters<P1, P2, P3, Out>(
    _ p1: P1,
    _ p2: P2,
    _ p3: P3,
    _ function: @escaping (P1, P2, P3, @escaping CompletionHandler<Out>) -> Void) -> AsyncRequest<Out>
{
    { function(p1, p2, p3, $0) }
}

public func eraseParameters<P1, P2, P3, P4, Out>(
    _ p1: P1,
    _ p2: P2,
    _ p3: P3,
    _ p4: P4,
    _ function: @escaping (P1, P2, P3, P4, @escaping CompletionHandler<Out>) -> Void) -> AsyncRequest<Out>
{
    { function(p1, p2, p3, p4, $0) }
}
