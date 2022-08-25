import Foundation
import ObjectiveC

private class KeySource {
    static private let writeSafe = WriteSafe()
    static private var map: [String: NSObject] = [:]
    static func pointer(for name: String) -> UnsafeRawPointer {
        let obj: NSObject = writeSafe.perform {
            if let result = map[name] {
                return result
            }
            let result = NSObject()
            map[name] = result
            return result
        }
        return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
    }
}

public protocol Associatable: AnyObject {}

public extension Associatable {
    func associatedObject<T: AnyObject>(name: String = #function, makeDefault: () -> T) -> T {
        let key = KeySource.pointer(for: name)
        if let result = objc_getAssociatedObject(self, key) as? T {
            return result
        }
        let result = makeDefault()
        objc_setAssociatedObject(self, key, result, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return result
    }
}

extension NSObject: Associatable {}
