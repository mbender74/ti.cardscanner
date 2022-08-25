import Foundation

public extension Optional {
    func unwrap<E: Error>(orThrow error: E) throws -> Wrapped {
        if let result = self {
            return result
        }
        throw error
    }
}

/// For use in extension where clauses
public protocol OptionalProtocol {
    associatedtype Wrapped
    var wrapped: Wrapped? { get }
    @inlinable func flatMap<U>(_ transform: (Wrapped) throws -> U?) rethrows -> U?
}

extension Optional: OptionalProtocol {
    public var wrapped: Wrapped? {
        return self
    }
}
