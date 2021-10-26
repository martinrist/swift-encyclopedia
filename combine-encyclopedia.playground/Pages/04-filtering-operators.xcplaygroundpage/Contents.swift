//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "filter") {
  let numbers = (1...10).publisher

  numbers
    .filter { $0.isMultiple(of: 3) }
    .sink(receiveValue: { print("\($0) is a multiple of 3") })
    .store(in: &subscriptions)
}

example(of: "removeDuplicates") {
  let words = "hey hey there! want to listen to mister mister ?"
    .components(separatedBy: " ")
    .publisher

  words
    .removeDuplicates()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "compactMap") {
  let strings = ["a", "1.24", "3", "def", "45", "0.23"]
    .publisher

  strings
    .compactMap { Float($0) }
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "ignoreOutput") {
  let numbers = (1...10_000).publisher

  numbers
    .ignoreOutput()
    .sink(receiveCompletion: { print("Completed with", $0)},
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "first(where:)") {
  let numbers = (1...9).publisher

  numbers
    .print()
    .first(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with:", $0)},
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "last(where:)") {
  let numbers = (1...9).publisher

  numbers
    .print()
    .last(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with:", $0)},
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "prefix") {
  let numbers = (1...9).publisher

  numbers
    .prefix(2)
    .sink(receiveCompletion: { print("Completed with:", $0)},
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "prefix(while:)") {
  let numbers = (1...9).publisher

  numbers
    .prefix { $0 < 6 }
    .sink(receiveCompletion: { print("Completed with:", $0)},
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "prefix(untilOutputFrom:)") {
  let isReady = PassthroughSubject<Void, Never>()
  let taps = PassthroughSubject<Int, Never>()

  taps
    .prefix(untilOutputFrom: isReady)
    .sink(receiveCompletion: { print("Completed with:", $0)},
          receiveValue: { print($0) })
    .store(in: &subscriptions)

  (1...5).forEach { n in
    taps.send(n)

    if n == 2 {
      isReady.send()
    }
  }
}

example(of: "drop(while:)") {
  let numbers = (1...10).publisher

  numbers
    .drop(while: { $0 % 5 != 0} )
    .sink(receiveCompletion: { print("Completed with:", $0)},
          receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//: [Next](@next)
