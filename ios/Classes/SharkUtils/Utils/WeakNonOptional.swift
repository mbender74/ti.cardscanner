
import Foundation

/**
 The intended purpose is NOT avoid the unwrapping optionals, for example in the case of delegates.
 
 The intended purpose is to return the existing instance when an exiisting value is currently in use BUT return a fresh instance when not.
 In a way a weak singleton (may WeakSingleton would be a better name),
 
 The main case for this to reduce side effects of singletons in unit tests by providing a new instance for each test; assuming there is no memory leaks which would still be a real bug in of its self.
 As we resolve the dependancy injection setup WeakNonOptional may become redundent.
 
 NOTES FOR USE:
 - Avoid should avoid storing `sut` (Subject Under Test) on XCTestCase properties or instances will be retained between tests
 
 NOTES FOR CHANGE:
 - If for some reason the use case for change the builder becomes a requirement, make an additional type since that would introduce dependancy between unit tests which breaks the current make use case
 */
@propertyWrapper public class WeakNonOptional<Value: AnyObject> {

    private let writeSafe = WriteSafe()
    private let builder: () -> Value
    private weak var liveValue: Value?

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        self.builder = wrappedValue
    }
    public init(wrappedValue: @escaping () -> Value) {
        self.builder = wrappedValue
    }

    // Can be used in unit tests to assert we do not have a leak from a previous test
    public var hasLiveValue: Bool {
        writeSafe.perform { liveValue != nil }
    }

    public var wrappedValue: Value {
        get {
            writeSafe.perform {
                let result = liveValue ?? builder()
                liveValue = result
                return result
            }
        }
        set {
            writeSafe.perform { liveValue = newValue }
        }
    }
}
