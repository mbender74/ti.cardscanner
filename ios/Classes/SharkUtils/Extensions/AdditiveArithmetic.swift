import Foundation

public extension AdditiveArithmetic where Self: ExpressibleByIntegerLiteral {
    // A bit clearer when using a counter. Generally avoid as in most cases += 1 or -= 1 is clearer.
    mutating func increment() {
        self += 1
    }
    mutating func decrement() {
        self -= 1
    }
}
