//: [Previous](@previous)
//: ## [13 - Inheritance](https://docs.swift.org/swift-book/LanguageGuide/Inheritance.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 14 - 'Advanced Classes'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/14-advanced-classes)
 */


//: ### Defining a Base Class

//: Any class that does not inherit from another is known as a _base class_.  There's no universal base class, like Java's `Object`:

class Vehicle {
  var currentSpeed = 0.0
  var description: String {
    return "travelling at \(currentSpeed) mph"
  }
  func makeNoise() {
    // No nothing - an arbitrary vehicle doesn't necessarily make a noise
  }
}

let someVehicle = Vehicle()
someVehicle.description


//: ### Subclassing

//: _Subclassing_ creates a new class based on an existing class.  Characteristics from the existing class are inherited, then refined:
class Bicycle: Vehicle {
  // New stored property
  var hasBasket = false
}

let bicycle1 = Bicycle()
bicycle1.hasBasket = true

bicycle1.currentSpeed = 15.0
bicycle1.description              // Accessing the inherited `description` property


//: ### Overriding
//: Subclasses can _override_ superclass methods, properties and subscripts using the `override` keyword, and can access the superclass version using `super`:

class Train: Vehicle {
  override func makeNoise() {
    super.makeNoise()             // Calls `Vehicle.makeNoise()`
    print("Choo choo!")
  }
  override var description: String {
    return "Train: " + super.description
  }
}

let train = Train()
train.description

//: Can provide a custom getter / setter to override any inherited property regardless of whether that inherited property is computed or stored:

class Car: Vehicle {
  var gear = 1

  // Overrides `description` computed property from `Vehicle`
  override var description: String {
    return super.description + " in gear \(gear)"
  }
}

let car = Car()
car.currentSpeed = 30
car.description

//: Can also override property observers to be notified when the value of an inherited property changes:
class AutomaticCar: Car {
  
  // Adds an observer to `currentSpeed` so that it sets the gear automatically
  override var currentSpeed: Double {
    didSet {
      gear = Int(currentSpeed / 10.0) + 1
    }
  }
}

let automaticCar = AutomaticCar()
automaticCar.description

automaticCar.currentSpeed = 30
automaticCar.description


//: ### Preventing overrides

//: Can prevent method, property or subscript from being overridden by marking it `final`.  Can also make an entire class final using `final` modifier.

//: [Next](@next)
