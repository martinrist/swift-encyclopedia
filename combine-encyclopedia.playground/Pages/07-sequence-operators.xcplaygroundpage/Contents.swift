//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "min") {
  let publisher = [1, -50, 246, 0].publisher

  publisher
    .min()
    .sink(receiveValue: { print("Lowest value is \($0)") })
    .store(in: &subscriptions)
}

example(of: "max") {
  let publisher = ["A", "F", "Z", "E"].publisher

  publisher
    .max()
    .sink(receiveValue: { print("Highest value is \($0)") })
    .store(in: &subscriptions)
}

example(of: "count") {
  let publisher = ["A", "B", "C", "D"].publisher

  publisher
    .count()
    .sink(receiveValue: { print("I have \($0) items") })
    .store(in: &subscriptions)
}

example(of: "output(at:)") {
  let publisher = ["A", "B", "C"].publisher

  publisher
    .output(at: 1)
    .sink(receiveValue: { print("Value at index 1 is \($0)") })
    .store(in: &subscriptions)
}

example(of: "output(in:)") {
  let publisher = ["A", "B", "C", "D", "E"].publisher

  publisher
    .output(in: 1...3)
    .sink(receiveValue: { print("Value in range \($0)") })
    .store(in: &subscriptions)
}

//: [Next](@next)
