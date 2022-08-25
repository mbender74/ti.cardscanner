import Foundation

/**
 Will be redundent when we move to Combine
 */

public func repeatingRequest(timeInterval: TimeInterval, _ request: @escaping AsyncRequest<Any>) -> Any {
    repeatingRequest(timeInterval: { timeInterval }, request)
}

public func repeatingRequest(timeInterval: @escaping () -> TimeInterval, _ request: @escaping AsyncRequest<Any>) -> Any {
    class Inner {
        let timeInterval: () -> TimeInterval
        let request: AsyncRequest<Any>
        init(timeInterval: @escaping () -> TimeInterval, request: @escaping AsyncRequest<Any>) {
            self.timeInterval = timeInterval
            self.request = request
            run()
        }
        func run() {
            Timer.scheduledTimer(withTimeInterval: timeInterval(), repeats: false, block: { [weak self] _ in
                self?.request { _ in self?.run() }
            })
        }
    }
    return Inner(timeInterval: timeInterval, request: request)
}
