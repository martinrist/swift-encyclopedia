//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "NotificationCenter") {
  let center = NotificationCenter.default
  let myNotification = Notification.Name("MyNotification")

  let publisher = center.publisher(for: myNotification, object: nil)

  let subscription = publisher
    .print()
    .sink { _ in
      print("Notification received from a publisher!")
    }

  print("Posting a notification")
  center.post(name: myNotification, object: nil)
  subscription.cancel()
}

example(of: "Just") {
  let just = Just("Hello World")

  just
    .sink(
      receiveCompletion: {
        print("Received completion", $0)
      },
      receiveValue: {
        print("Received value", $0)
      })
    .store(in: &subscriptions)
}


example(of: "assign(to:on:)") {
  class SomeObject {
    var value: String = "" {
      didSet {
        print(value)
      }
    }
  }

  let object = SomeObject()

  ["Hello", "World!"].publisher
    .assign(to: \.value, on: object)
    .store(in: &subscriptions)
}


example(of: "PassthroughSubject") {
  let subject = PassthroughSubject<String, Never>()

  subject
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

  subject.send("Hello")
  subject.send("World!")
  subject.send(completion: .finished)

  // This won't get to the subscriber
  subject.send("Still there?")
}


example(of: "CurrentValueSubject") {
  let subject = CurrentValueSubject<Int, Never>(0)

  subject
    .print()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

  print(subject.value)
  subject.send(1)
  subject.send(2)
  print(subject.value)
  subject.value = 42
  subject.send(completion: .finished)

  // After completion, you can still set and retrieve the value,
  // but the subscriber won't see the changes.
  print(subject.value)
  subject.value = 666
  print(subject.value)
}


example(of: "Type erasure") {
  let subject = PassthroughSubject<Int, Never>()

  let publisher = subject.eraseToAnyPublisher()

//  publisher.send(0)

  publisher
    .print()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

  subject.send(0)
}


example(of: "Future") {
  func futureIncrement(
    integer: Int,
    afterDelay delay: TimeInterval) -> Future<Int, Never> {
      Future<Int, Never> { promise in
        print("In Future closure")
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
          promise(.success(integer + 1))
        }
      }
    }

  let future = futureIncrement(integer: 41, afterDelay: 3)

  future
    .share()
    .sink(
      receiveCompletion: { print("First", $0) },
      receiveValue: { print("First", $0) })
    .store(in: &subscriptions)

  future
    .sink(
      receiveCompletion: { print("Second", $0) },
      receiveValue: { print("Second", $0) })
    .store(in: &subscriptions)

  DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    future
      .sink(
        receiveCompletion: { print("Third", $0) },
        receiveValue: { print("Third", $0) })
      .store(in: &subscriptions)
  }

}


//: [Next](@next)
