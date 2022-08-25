@propertyWrapper
public struct ThreadSafe<T> {
    private let writeSafe: WriteSafe
    public var unsafeValue: T
    public var wrappedValue: T {
        get { writeSafe.perform { unsafeValue } }
        set { writeSafe.perform { unsafeValue = newValue } }
    }
    public init(wrappedValue: T, writeSafe: WriteSafe = WriteSafe()) {
        self.unsafeValue = wrappedValue
        self.writeSafe = writeSafe
    }
}
