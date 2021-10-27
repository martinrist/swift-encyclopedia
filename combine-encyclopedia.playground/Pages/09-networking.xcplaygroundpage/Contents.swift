//: [Previous](@previous)

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

struct Todo: Codable {
  let userId: Int
  let id: Int
  let title: String
  let completed: Bool
}

example(of: "dataTaskPublisher") {
  URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
    .sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        print("Finished!")
      case .failure(let error):
        print("Retrieving data failed with error \(error)")
      }
    }, receiveValue: { data, response in
      print("Retrieved data of size \(data.count)")
    })
    .store(in: &subscriptions)
}

example(of: "dataTaskPublisher and decode") {

  URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
    .map(\.data)
    .decode(type: Todo.self, decoder: JSONDecoder())
    .sink(receiveCompletion: { completion in
      switch completion {
      case .finished:
        print("Finished!")
      case .failure(let error):
        print("Retrieving data failed with error \(error)")
      }
    }, receiveValue: { todo in
      print("Retrieved todo item: \(todo)")
    })
    .store(in: &subscriptions)
}

example(of: "Multiple Subscribers without multicast()") {

  let publisher = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
    .map(\.data)
    .decode(type: Todo.self, decoder: JSONDecoder())
    .share()

  publisher
    .sink(
      receiveCompletion: { print("Subscriber 1 finished with: \($0)")},
      receiveValue: { print("Subscriber 1 got value: \($0)") })
    .store(in: &subscriptions)

  DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    publisher
    .sink(
      receiveCompletion: { print("Subscriber 2 finished with: \($0)")},
      receiveValue: { print("Subscriber 2 got value: \($0)") })
    .store(in: &subscriptions)
  }

}

example(of: "Multiple Subscribers with multicast()") {

  let publisher = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://jsonplaceholder.typicode.com/todos/1")!)
    .map(\.data)
    .decode(type: Todo.self, decoder: JSONDecoder())
    .multicast { PassthroughSubject<Todo, Error>() }

  publisher
    .sink(
      receiveCompletion: { print("Subscriber 1 finished with: \($0)")},
      receiveValue: { print("Subscriber 1 got value: \($0)") })
    .store(in: &subscriptions)

  publisher
    .sink(
      receiveCompletion: { print("Subscriber 2 finished with: \($0)")},
      receiveValue: { print("Subscriber 1 got value: \($0)") })
    .store(in: &subscriptions)

  publisher.connect()
    .store(in: &subscriptions)
}


//: [Next](@next)
