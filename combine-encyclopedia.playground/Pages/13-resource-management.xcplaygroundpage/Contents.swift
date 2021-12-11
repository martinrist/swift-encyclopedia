//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "share()") {

    let shared = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
        .map(\.data)
        .print("shared")
        .share()

    print("subscribing shared first")
    shared.sink(
        receiveCompletion: { _ in },
        receiveValue: { print("shared subscription1 received: '\($0)'") }
    ).store(in: &subscriptions)

    print("subscribing shared second")
    shared.sink(
        receiveCompletion: { _ in },
        receiveValue: { print("shared subscription2 received: '\($0)'") }
    ).store(in: &subscriptions)

}

example(of: "multicast(_:)") {
    let subject = PassthroughSubject<Data, URLError>()

    let multicasted = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
        .map(\.data)
        .print("multicast")
        .multicast(subject: subject)

    print("subscribing multicasted first")
    multicasted.sink(
        receiveCompletion: { _ in },
        receiveValue: { print("multicasted subscription1 received: '\($0)'") }
    ).store(in: &subscriptions)

    print("subscribing second")
    multicasted.sink(
        receiveCompletion: { _ in },
        receiveValue: { print("multicasted subscription2 received: '\($0)'") }
    ).store(in: &subscriptions)

    multicasted.connect().store(in: &subscriptions)
}

example(of: "Future") {

    func performWork() throws -> Int {
        print("Performing work and returning result")
        return 42
    }

    let future = Future<Int, Error> { promise in
        do {
            let result = try performWork()
            promise(.success(result))
        } catch {
            promise(.failure(error))
        }
    }

    print("Subscribing to future...")

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        future.sink(
            receiveCompletion: { _ in print("future subscription1 completed")},
            receiveValue: { print("future subscription1 received: '\($0)'") }
        )
    }

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        future.sink(
            receiveCompletion: { _ in print("future subscription2 completed")},
            receiveValue: { print("future subscription2 received: '\($0)'") }
        )
    }
}

//: [Next](@next)
