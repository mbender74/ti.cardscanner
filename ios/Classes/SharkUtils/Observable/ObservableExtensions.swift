import Foundation

public extension Observable where T: Equatable {
    func sync<NewT: Equatable>(_ keyPath: WritableKeyPath<T, NewT>, onto observable: Observable<NewT>, initaliseWithOntoValue: Bool = false) {
        observable.syncingTokens.append(
            observeFromNextValue(priority: .observerSyncing, weakClosure(observable) {
                if $0.value != $1[keyPath: keyPath] {
                    observable.value = $1[keyPath: keyPath]
                }
            })
        )
        syncingTokens.append(
            observable.observeFromNextValue(priority: .observerSyncing, weakClosure(self) {
                if $0.value[keyPath: keyPath] != $1 {
                    $0.value[keyPath: keyPath] = $1
                }
            })
        )
        if observable.value != value[keyPath: keyPath] {
            if initaliseWithOntoValue {
                value[keyPath: keyPath] = observable.value
            } else {
                observable.value = value[keyPath: keyPath]
            }
        }
    }
    
    func synced<NewT: Equatable>(_ keyPath: WritableKeyPath<T, NewT>) -> Observable<NewT> {
        let result = Observable<NewT>.onChange(value[keyPath: keyPath])
        sync(keyPath, onto: result)
        return result
    }
    
    static func onChange(_ value: T) -> Observable<T> {
        let result = Observable(value)
        result.notifcationBehaviour = .onChange
        return result
    }
}

public extension Observable {
    static func onSet(_ value: T) -> Observable<T> {
        let result = Observable(value)
        result.notifcationBehaviour = .onSet
        return result
    }
}
