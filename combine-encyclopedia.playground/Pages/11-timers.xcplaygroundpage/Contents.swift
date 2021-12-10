//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "RunLoop") {
    let runLoop = RunLoop.main

    let subscription = runLoop.schedule(
        after: runLoop.now,
        interval: .seconds(1),
        tolerance: .milliseconds(100)) {
            print("RunLoop - Timer fired")
        }

    runLoop.schedule(
        after: .init(Date(timeIntervalSinceNow: 3.0))) {
            subscription.cancel()
        }
}

example(of: "Timer") {
    let publisher = Timer.publish(every: 1.0, on: .main, in: .common)

    let subscription = publisher
        .autoconnect()
        .scan(0) { counter, _ in counter + 1 }
        .sink { counter in
            print("Timer - Counter is \(counter)")
        }

    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        subscription.cancel()
    }

}

example(of: "DispatchQueue") {

    let queue = DispatchQueue.main
    let source = PassthroughSubject<Int, Never>()

    var counter = 0

    let cancellable = queue.schedule(
        after: queue.now,
        interval: .seconds(1)
    ) {
        source.send(counter)
        counter += 1
    }

    cancellable.store(in: &subscriptions)

    source.sink {
        print("DispatchQueue - Timer emitted \($0)")
    }
        .store(in: &subscriptions)
}

//: [Next](@next)
