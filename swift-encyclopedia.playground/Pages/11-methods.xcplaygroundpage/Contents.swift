//: [Previous](@previous)
//: ## [11 - Methods](https://docs.swift.org/swift-book/LanguageGuide/Methods.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 12 - 'Methods'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/12-methods)
 */


//: ### Instance Methods

//: Instance methods are functions that belong to instances of a class, structure or enumeration.  They have the same syntax as functions, but are lexically scoped within the declaring type:

class Counter {
  var count = 0

  func increment() {
    count += 1
  }

  func increment(by amount: Int) {
    count += amount
  }

  func reset() {
    count = 0
  }
}

let counter = Counter()
counter.count
counter.increment()
counter.count
counter.increment(by: 10)

//: Every instance of a type has an implicit property called `self`, which is exactly equivalent to the instance itself.  Sometimes `self` is needed to disambiguate between a local variable / method argument, and a property of the type.

//: By default, the properties of a value type can't be modified from within its instance methods, even if those properties are declared with `var`.  To opt into this behaviour, use the `mutating` keyword:

struct Point {
  var x = 0.0, y = 0.0
  mutating func moveBy1(x deltaX: Double, y deltaY: Double) {
    x += deltaX
    y += deltaY
  }

  // `mutating` methods can also assign a new instance to `self`.
  // The end result is identical to `moveBy1`
  mutating func moveBy2(x deltaX: Double, y deltaY: Double) {
    self = Point(x: x + deltaX, y: y + deltaY)
  }
}

var somePoint = Point(x: 1.0, y: 1.0)       // Must be `var` to use mutating method
somePoint.moveBy1(x: 2.0, y: 3.0)
(somePoint.x, somePoint.y)
somePoint.moveBy2(x: 4.0, y: 5.0)
(somePoint.x, somePoint.y)

//: `mutating` methods for enumerations can set `self` to a different case, e.g. to implement a state machine:
enum TriStateSwitch {
  case off, low, high
  mutating func next() {
    switch self {
    case .off:
      self = .low
    case .low:
      self = .high
    case .high:
      self = .off
    }
  }
}
var ovenLight = TriStateSwitch.off
ovenLight.next()
ovenLight.next()
ovenLight.next()

//: Methods are typically used where there is a non-trivial amount (i.e. not `O(1)`) of work to do.  If there's just a simple `O(1)` calculation, or if a setter is also required, it's often better to use a _computed property_.


//: ### Type Methods

//: Like with properties, methods can be declared on a type using the `static` keyword.  For classes they can also be declared `class` to enable them to be overridden:

struct SomeStruct {
  static func someTypeMethod(){
    print("someTypeMethod() called")
  }
}

class SomeClass {
  static func someTypeMethod() {
    print("someTypeMethod() called")
  }
  class func someOverrideableTypeMethod() {
    print("someOverrideableTypeMethod() called")
  }
}

class SomeSubClass: SomeClass {
  override class func someOverrideableTypeMethod() {
    print("overridden version of someOverrideableTypeMethod()")
  }
}

SomeSubClass.someOverrideableTypeMethod()

//: [Next](@next)
