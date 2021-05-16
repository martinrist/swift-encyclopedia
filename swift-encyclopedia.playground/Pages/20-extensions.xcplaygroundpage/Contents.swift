//: [Previous](@previous)
//: ## [20 - Extensions](https://docs.swift.org/swift-book/LanguageGuide/Extensions.html)

//: ### Extension Syntax

/*:
 Extensions add new functionality to an existing type, allowing addition of:
 - Computed instance and type properties
 - Instance and type methods
 - Initialisers
 - Subscripts
 - Nested types
 - Protocol conformances
 */

struct SomeType { }

extension SomeType {
  // new functionality added to SomeType here
}

protocol SomeProtocol {
  func doStuff()
}

protocol AnotherProtocol {
  func doMoreStuff()
}

extension SomeType: SomeProtocol, AnotherProtocol {
  func doStuff() {
    print("Doing stuff")
  }

  func doMoreStuff() {
    print("Doing more stuff")
  }

}

SomeType().doStuff()
SomeType().doMoreStuff()
print()


//: ### Computed Properties

//: Extensions can add computed instance and type properties to existing types:

extension Double {
  var km: Double { return self * 1_000.0 }
  var m:  Double { return self }
  var cm: Double { return self / 100.0 }
  var mm: Double { return self / 1000.0 }
  var ft: Double { return self / 3.28084 }
}

let oneInchInMetres = 25.4.mm
let threeFeetInMetres = 3.ft

//: However, extensions may not contain stored properties, or add property observers to existing properties
//extension Int {
//  var extraProperty: Int
//}


//: ### Initialisers

//: Extensions can add new convenience initialisers to existing types, enabling extension of other types to accept your own custom types as initialiser parameters.  However, they cannot add designated initalisers or deinitialisers.


//: ### Methods

//: Extensions can add new instance and type methods to existing types:

extension Int {
  func times(task: () -> Void) {
    for _ in 0..<self {
      task()
    }
  }
}

3.times { print("Hi!") }
print()


//: Instance methods added with an extension can also mutate the instance itself:
extension Int {
  // Since `Int` is a struct, `mutating` is required here
  mutating func square() {
    self = self * self
  }
}

var someInt = 3
someInt.square()


//: ### Subscripts

//: Extensions can add new subscripts to an existing type:

extension Int {
  subscript(digitIndex: Int) -> Int {
    var decimalBase = 1
    for _ in 0..<digitIndex {
      decimalBase *= 10
    }
    return (self / decimalBase) % 10
  }
}

746381295[0]
746381295[1]
123[5]


//: ### Nested Types

//: Extensions can add new nested types to existing classes, structs and enums:

extension Int {
  enum Kind {
    case negative, zero, positive
  }
  var kind: Kind {
    switch self {
    case 0:
      return .zero
    case let x where x > 0:
      return .positive
    default:
      return .negative
    }
  }
}

1.kind
0.kind
(-1).kind

//: [Next](@next)
