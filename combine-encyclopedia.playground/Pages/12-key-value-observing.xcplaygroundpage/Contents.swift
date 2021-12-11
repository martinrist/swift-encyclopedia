//: [Previous](@previous)

import Foundation
import Combine

example(of: "publisher(for:options:)") {
    let queue = OperationQueue()

    queue.publisher(for: \.operationCount)
        .sink {
            print("Outstanding operations in queue: \($0)")
        }

    queue.addOperation {
        print("Operation 1")
    }
    queue.addOperation {
        print("Operation 2")
    }
    queue.addOperation {
        print("Operation 3")
    }
    queue.addOperation {
        print("Operation 4")
    }

}

example(of: "Custom KVO-compliant classes") {
    class TestObject: NSObject {
        @objc dynamic var integerProperty = 0
        @objc dynamic var stringProperty = ""
        @objc dynamic var arrayProperty: [Float] = []

    }

    let obj = TestObject()

    obj.publisher(for: \.integerProperty)
        .sink {
            print("integerProperty changes to \($0)")
        }

    obj.publisher(for: \.stringProperty)
        .sink {
            print("stringProperty changes to \($0)")
        }

    obj.publisher(for: \.arrayProperty)
        .sink {
            print("arrayProperty changes to \($0)")
        }

    obj.integerProperty = 100
    obj.integerProperty = 200
    obj.stringProperty = "Hello"
    obj.arrayProperty = [1.0]
    obj.stringProperty = "World"
    obj.arrayProperty = [1.0, 2.0]
}

example(of: "ObservableObject") {
    class MonitorObject: ObservableObject {
        @Published var someProperty = false
        @Published var someOtherProperty = ""
    }

    let object = MonitorObject()
    object.objectWillChange.sink {
        print("object will change")
    }

    object.someProperty = true
    object.someOtherProperty = "Hello World"
}

//: [Next](@next)
