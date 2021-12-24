//: [Previous](@previous)

import Foundation
import Combine
import UIKit

var subscriptions = Set<AnyCancellable>()

enum MyError: Error {
    case ohNo
}

example(of: "Never sink") {
    Just("Hello")
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "setFailureType") {
    Just("Hello")
        .setFailureType(to: MyError.self)
        .sink { completion in
            switch completion {
            case .failure(.ohNo):
                print("Finished with Oh No!")
            case .finished:
                print("Finished successfully!")
            }
        } receiveValue: { value in
            print("Got value: \(value)")
        }
        .store(in: &subscriptions)
}

example(of: "assign(to:on:)") {

    class Person {
        let id = UUID()
        var name = "Unknown"
    }

    let person = Person()
    print("1", person.name)

    Just("Martin")
    // Uncommenting the following line will cause a compilation error
    // .setFailureType(to: Error.self)
        .handleEvents(receiveCompletion: { _ in print("2", person.name) })
        .assign(to: \.name, on: person)
        .store(in: &subscriptions)
}

example(of: "assign(to:)") {
    class MyViewModel: ObservableObject {
        @Published var currentDate = Date()
        init() {
            Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .prefix(3)
            // The following line captures `self` strongly
            //                .assign(to: \.currentDate, on: self)
            //                .store(in: &subscriptions)

            // use this to avoid the retain cycle
                .assign(to: &$currentDate)
        }
    }

    let vm = MyViewModel()
    vm.$currentDate
        .sink(receiveValue: { print($0) })
        .store(in: &subscriptions)
}

example(of: "assertNoFailure") {
    Just("Hello")
        .setFailureType(to: MyError.self)
    // Uncommenting this line will cause a crash on `assertNoFailure()`
    // .tryMap { _ in throw MyError.ohNo }
        .assertNoFailure()
        .sink(receiveValue: { print("Got value: \($0)" )})
        .store(in: &subscriptions)
}

example(of: "tryMap") {
    enum NameError: Error {
        case tooShort(String)
        case unknown
    }
    ["Martin", "Paul", "Florence"]
        .publisher
        .tryMap { value -> Int in
            guard value.count >= 5 else {
                throw NameError.tooShort(value)
            }
            return value.count
        }
        .sink(receiveCompletion: { print("Completed with \($0)") },
              receiveValue: { print("Got value: \($0)") })
}

example(of: "tryMap and mapError") {
    enum NameError: Error {
        case tooShort(String)
        case unknown
    }

    Just("Hello")
        .setFailureType(to: NameError.self)
        .tryMap { $0 + " World!" }
        .mapError { $0 as? NameError ?? .unknown }
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                print("Done!")
            case .failure(.tooShort(let name)):
                print("\(name) is too short!")
            case .failure(.unknown):
                print("An unknown error occurred")
            }
        },
              receiveValue: { print("Got value \($0)") })
        .store(in: &subscriptions)
}

example(of: "Joke API") {
    class DadJokes {
        struct Joke: Codable {
            let id: String
            let joke: String
        }

        enum Error: Swift.Error, CustomStringConvertible {
            case network
            case jokeDoesntExist(id: String)
            case parsing
            case unknown

            var description: String {
                switch self {
                case .network:
                    return "Request to API Server failed"
                case .parsing:
                    return "Failed parsing response from server"
                case .jokeDoesntExist(let id):
                    return "Joke with ID \(id) doesn't exist"
                case .unknown:
                    return "An unknown error occurred"
                }
            }
        }

        func getJoke(id: String) -> AnyPublisher<Joke, DadJokes.Error> {

            guard id.rangeOfCharacter(from: .letters) != nil else {
                return Fail<Joke, Error>(error: .jokeDoesntExist(id: id))
                    .eraseToAnyPublisher()
            }

            let url = URL(string: "https://icanhazdadjoke.com/j/\(id)")!
            var request = URLRequest(url: url)
            request.allHTTPHeaderFields = ["Accept": "application/json"]

            return URLSession.shared
                .dataTaskPublisher(for: request)
                .tryMap { data, _ -> Data in
                    guard let obj = try? JSONSerialization.jsonObject(with: data),
                          let dict = obj as? [String: Any],
                          dict["status"] as? Int == 404 else {
                              return data
                          }
                    throw DadJokes.Error.jokeDoesntExist(id: id)
                }
                .decode(type: Joke.self, decoder: JSONDecoder())
                .mapError { error -> DadJokes.Error in
                    switch error {
                    case is URLError:
                        return .network
                    case is DecodingError:
                        return .parsing
                    default: return error as? DadJokes.Error ?? .unknown
                    }
                }
                .eraseToAnyPublisher()
        }
    }

    let api = DadJokes()
    let jokeId = "9prWnjyImyd"
//    let badJokeId = "123456"

    api
        .getJoke(id: jokeId)
//        .getJoke(id: badJokeId)
        .sink(receiveCompletion: { print($0) },
              receiveValue: { print("Got joke: \($0)") })
        .store(in: &subscriptions)
}

let photoService = PhotoService()

example(of: "Catching and retrying") {
    photoService
        // Use the following line to fail retrieval twice before succeeding
        // .fetchPhoto(quality: .high, failingTimes: 2)
        .fetchPhoto(quality: .high)
        .handleEvents(
            receiveSubscription: { _ in print("Trying...") },
            receiveCompletion: {
                guard case .failure(let error) = $0 else { return }
                print("Got error: \(error)")
            })
        .retry(3)
        .catch { error -> PhotoService.Publisher in
            print("Failed fetching high quality, falling back to low quality")
            return photoService.fetchPhoto(quality: .low)
        }
        .replaceError(with: UIImage(named: "na.jpg")!)
        .sink(
            receiveCompletion: { print("\($0)") },
            receiveValue: { image in
                image
                print("Got image: \(image)")
            }
        )
        .store(in: &subscriptions)
}


//: [Next](@next)
