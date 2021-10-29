//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "print(_:)") {
  (1...3).publisher
    .print("publisher")
    .sink { _ in }
    .store(in: &subscriptions)
}

example(of: "print(_:to:)") {
  class TimeLogger: TextOutputStream {
    private var previous = Date()
    private let formatter = NumberFormatter()

    init() {
      formatter.maximumFractionDigits = 5
      formatter.minimumFractionDigits = 5
    }

    func write(_ string: String) {
      let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
      guard !trimmed.isEmpty else { return }
      let now = Date()
      print("+\(formatter.string(for: now.timeIntervalSince(previous))!)s: \(string)")
      previous = now
    }
  }

  (1...3).publisher
    .print("publisher", to: TimeLogger())
    .sink { _ in }
    .store(in: &subscriptions)
}

example(of: "handleEvents()") {

  let request = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com/")!)

  request
    .handleEvents(receiveSubscription: { _ in
      print("Network request will start")
    }, receiveOutput: { _ in
      print("Network request data received")
    }, receiveCancel: {
      print("Network request cancelled")
    })
    .sink(receiveCompletion: { completion in
      print("Sink received completion: \(completion)")
    }) { (data, _) in
      print("Sink received data: \(data)")
    }
    .store(in: &subscriptions)

}

example(of: "breakpointOnError") {
  (1...3).publisher
    .breakpointOnError()                    // Won't work in Playgrounds
    .sink { print($0) }
    .store(in: &subscriptions)
}

example(of: "breakpoint") {
  (1...3).publisher
    .breakpoint(receiveOutput: { value in   // Won't work in Playgrounds
      value > 10 && value < 15
    })
    .sink { print($0) }
    .store(in: &subscriptions)
}

//: [Next](@next)
