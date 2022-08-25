import Foundation

public struct ObserverPriority: Comparable {
    private var _value: Int
    public var value: Int {
        get {
            _value
        }
        set {
            _value = min(1000, max(-1000, newValue))
        }
    }
    public init(value: Int) {
        self._value = min(1000, max(-1000, value))
    }
    
    /// let the cells update first then updates will animate
    public static let cellContainer = ObserverPriority(value: -100)
    public static let standard = ObserverPriority(value: 0)
    public static let observerSyncing = ObserverPriority(value: 500)// I think I dont need but will remove later
    public static func custom(_ value: Int) -> ObserverPriority {
        ObserverPriority(value: value)
    }
    
    public static func < (lhs: ObserverPriority, rhs: ObserverPriority) -> Bool {
        lhs.value < rhs.value
    }
}

public struct ValueChange<Value> {
    public var new: Value
    public var old: Value
}

extension ValueChange: Equatable where Value: Equatable {
    public var hasChange: Bool {
        new != old
    }
}

extension ValueChange {
    public func map<NewValue>(_ action: (Value) throws -> NewValue) rethrows -> ValueChange<NewValue> {
        ValueChange<NewValue>(
            new: try action(new),
            old: try action(old)
        )
    }
    
    public func hasChanged<Child: Equatable>(_ keyPath: KeyPath<Value, Child>) -> Bool {
        new[keyPath: keyPath] != old[keyPath: keyPath]
    }
}

public class ObserverSet<Value> {
    
    private class Observer: Comparable {
        let retained: Any?
        let priority: ObserverPriority
        let additionNumber: Int
        let action: (ValueChange<Value>) -> Void
        init(retained: Any?, priority: ObserverPriority, additionNumber: Int, action: @escaping (ValueChange<Value>) -> Void) {
            self.action = action
            self.priority = priority
            self.additionNumber = additionNumber
            self.retained = retained
        }
        
        static func < (lhs: ObserverSet<Value>.Observer, rhs: ObserverSet<Value>.Observer) -> Bool {
            lhs.priority > rhs.priority
                || (lhs.priority == rhs.priority && lhs.additionNumber < rhs.additionNumber)
        }
        
        static func == (lhs: ObserverSet<Value>.Observer, rhs: ObserverSet<Value>.Observer) -> Bool {
            lhs.priority.value == rhs.priority.value
                && lhs.additionNumber == rhs.additionNumber
        }
    }

    private var observers = [WeakContainer<Observer>]()
    private var additionsCounter = 0
    private var runQueue: [ValueChange<Value>] = []
    public init() {}

    public func run(with values: ValueChange<Value>) {
        /*
         The a newValue can come or new observers be added in while notifying observers.
         
         The details below are just make that handle as you would expect
         
         1. all observers would be before the first change, then the next
         2. observers added while notifying observers will be notifity in this loop
         */
        
        observers.removeReleased()
        runQueue.append(values)
        if runQueue.count > 1 {
            return
        }
        
        var index = 0
        while index < runQueue.count {
            let values = runQueue[index]
            let observers = self.observers
            observers.forEach {
                $0.value?.action(values)
            }
            index.increment()
        }

        runQueue.removeAll()
    }

    public func add(retained: Any? = nil, priority: ObserverPriority = .standard, _ action: @escaping (Value) -> Void) -> AnyObject {
        addWithChange(retained: retained, priority: priority) {
            action($0.new)
        }
    }
    
    public func addWithChange(retained: Any? = nil, priority: ObserverPriority = .standard, _ action: @escaping (ValueChange<Value>) -> Void) -> AnyObject {
        let result = Observer(retained: retained, priority: priority, additionNumber: additionsCounter, action: action)
        observers.append(WeakContainer(result))
        observers.sort {
            guard let lhs = $0.value, let rhs = $1.value else {
                return true
            }
            return lhs < rhs
        }
        additionsCounter.increment()
        return result
    }
}
