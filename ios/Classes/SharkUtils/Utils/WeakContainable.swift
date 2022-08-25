import Foundation

public protocol WeakContainable {
    associatedtype Content: AnyObject
    var value: Content? { get }
}

public final class WeakContainer<T: AnyObject>: Equatable, WeakContainable {
    public private(set) weak var value: T?

    public init(_ value: T?) {
        self.value = value
    }

    public static func == (lhs: WeakContainer, rhs: WeakContainer) -> Bool {
        return lhs.value === rhs.value
    }
}

public extension Array where Element: WeakContainable {
    mutating func removeReleased() {
        removeAll { $0.value == nil }
    }

    var containedValues: [Element.Content] {
        return compactMap { $0.value }
    }
}
