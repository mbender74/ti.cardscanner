import Foundation

public extension Result {
    var successValue: Success? {
        try? get()
    }
    func mapError<SomeError>(_ error: SomeError) -> Result<Success, SomeError> {
        mapError { _ in error }
    }
    
    @discardableResult func ifSuccess(_ action: (Success) -> Void) -> Self {
        if let value = try? get() {
            action(value)
        }
        return self
    }
    
    @discardableResult func ifSuccess(_ action: () -> Void) -> Self {
        ifSuccess { _ in
            action()
        }
    }
    
    @discardableResult func ifFailure(_ action: (Failure) -> Void) -> Self {
        switch self {
        case .failure(let error):
            action(error)
        default:
            break
        }
        return self
    }
    
    @discardableResult func ifFailure(_ action: () -> Void) -> Self {
        ifFailure { _ in
            action()
        }
    }
    
    @discardableResult func forAll(_ action: (Self) -> Void) -> Self {
        action(self)
        return self
    }
    
    @discardableResult func forSuccess(_ action: (Self) -> Void) -> Self {
        ifSuccess {
            action(self)
        }
    }
    
    @discardableResult func forFailure(_ action: (Self) -> Void) -> Self {
        ifFailure { _ in
            action(self)
        }
    }
    
    @discardableResult func on(_ queue: DispatchQueue, _ action: @escaping (Self) -> Void) -> Self {
        queue.async {
            action(self)
        }
        return self
    }
    
    func fullMap<Out, Err: Error>(_ action: (Self) -> Result<Out, Err>) -> Result<Out, Err> {
        action(self)
    }
}

public extension Result where Success: OptionalProtocol {
    func mapNil(_ error: Failure) -> Result<Success.Wrapped, Failure> {
        flatMap { $0.flatMap { .success($0) } ?? .failure(error) }
    }
}
