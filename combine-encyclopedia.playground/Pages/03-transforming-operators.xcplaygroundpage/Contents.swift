//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "collect") {
  ["A", "B", "C", "D", "E"].publisher
    .collect()
    .sink(
      receiveCompletion: { print($0) },
      receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "collect(2)") {
  ["A", "B", "C", "D", "E"].publisher
    .collect(2)
    .sink(
      receiveCompletion: { print($0) },
      receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "map") {
  let formatter = NumberFormatter()
  formatter.numberStyle = .spellOut

  [123, 4, 56].publisher
    .map {
      formatter.string(for: NSNumber(integerLiteral: $0)) ?? ""
    }
    .sink(
      receiveCompletion: { print($0) },
      receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "map with key paths") {
  let publisher = PassthroughSubject<Coordinate, Never>()

  publisher
    .map(\.x, \.y)
    .sink { x, y in
      print("The coordinate at (\(x), \(y)) is in quadrant",
      quadrantOf(x: x, y: y))
    }
    .store(in: &subscriptions)

  publisher.send(Coordinate(x: 10, y: -8))
  publisher.send(Coordinate(x: 0, y: 5))
}

example(of: "replaceNil") {
  ["A", nil, "C"].publisher
    .replaceNil(with: "-")
    .map { $0! }
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "replaceEmpty") {
  let empty = Empty<String, Never>()

  empty
    .replaceEmpty(with: "Empty")
    .sink(
      receiveCompletion: { print($0) },
      receiveValue: { print($0) })
    .store(in: &subscriptions)
}

example(of: "scan") {
  var dailyGainLoss: Int { .random(in: -10...10) }

  let august2019 = (0..<22)
    .map { _ in dailyGainLoss }
    .publisher

  august2019
    .scan(50) { latest, current in
      max(0, latest + current)
    }
    .sink(receiveValue: { _ in })
    .store(in: &subscriptions)
}

example(of: "flatMap 1") {
  let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
  let james = Chatter(name: "James", message: "Hi, I'm James!")

  let chat = CurrentValueSubject<Chatter, Never>(charlotte)

  chat
    .flatMap(\.message)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

  charlotte.message.value = "Charlotte: How's it going?"
  chat.value = james

  james.message.value = "James: Doing great.  You?"
  charlotte.message.value = "Charlotte: I'm doing fine, thanks."
}

example(of: "flatMap 2") {
  func decode(_ codes: [Int]) -> AnyPublisher<String, Never> {
    Just(
      codes
        .compactMap { code in
          guard (32...255).contains(code) else { return nil }
          return String(UnicodeScalar(code) ?? " ")
        }
        .joined()
      )
      .eraseToAnyPublisher()
  }

  [72, 101, 108, 108, 111, 44, 32, 87, 111, 114, 108, 100, 33]
    .publisher
    .collect()
    .flatMap(decode)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
}

//: [Next](@next)
