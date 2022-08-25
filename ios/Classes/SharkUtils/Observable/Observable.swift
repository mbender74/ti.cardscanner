import Foundation
/**
 Other stuff we MAY look at
 -  Readonly stuff
 -  Discuss memory managment options and source of truth; they are kinda related
 - Thread safety but I think this should be app leave anyway
 */
public class Observable<T> {
    private let observerSet: ObserverSet<T> = ObserverSet()
    public var notifcationBehaviour: ObserveNotifcationBehaviour = .onSet
    public var syncingTokens: [AnyObject] = [] /// for helper creation use
    
    private var previousValue: T
    public var value: T  {
        didSet {
            if notifcationBehaviour.shouldNotify((value: value, oldValue: oldValue)) {
                previousValue = oldValue
                observerSet.run(with: .init(new: value, old: oldValue))
            }
        }
    }
    
    public init(_ value: T) {
        self.value = value
        self.previousValue = value
    }
    
    /// IS triggered when first added
    public func observeWithChange(priority: ObserverPriority = .standard, _ action: @escaping (ValueChange<T>) -> Void) -> AnyObject {
        let result = observerSet.addWithChange(priority: priority, action)
        action(.init(new: value, old: previousValue))
        return result
    }
    
    /// IS triggered when first added
    public func observeFromNextValueWithChange(priority: ObserverPriority = .standard, _ action: @escaping (ValueChange<T>) -> Void) -> AnyObject {
        observerSet.addWithChange(priority: priority, action)
    }
    
    /// IS triggered when first added
    public func observe(priority: ObserverPriority = .standard, _ action: @escaping (T) -> Void) -> AnyObject {
        let result = observerSet.add(priority: priority, action)
        action(value)
        return result
    }
    
    /// IS NOT triggered when first added
    public func observeFromNextValue(priority: ObserverPriority = .standard, _ action: @escaping (T) -> Void) -> AnyObject {
        observerSet.add(priority: priority, action)
    }
    
    /// perform multiple updates with 1 fire
    public func updated(_ action: (inout T) -> Void ) {
        var value = self.value
        action(&value)
        self.value = value
    }
}

public extension Observable {
    /**
     The only reason for the `struct` is so we can go
     
     `item.notifcationBehaviour = .onChange`
     */
    struct ObserveNotifcationBehaviour {
        let shouldNotify: ((value: T, oldValue: T)) -> Bool
        static var onSet: ObserveNotifcationBehaviour {
            ObserveNotifcationBehaviour { _ in
                true
            }
        }
    }
}

public extension Observable.ObserveNotifcationBehaviour where T: Equatable {
    static var onChange: Observable.ObserveNotifcationBehaviour {
        Observable.ObserveNotifcationBehaviour {
            $0 != $1
        }
    }
}

extension Observable: Chainable {}
