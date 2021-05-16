//: [Previous](@previous)
//: ## [14 - Initialisation](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 12 - 'Methods'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/12-methods)
 - [Swift Apprentice - Chapter 14 - 'Advanced Classes'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/14-advanced-classes)
 */


//: ### Setting Initial Values for Stored Properties

//: Classes and structs must set all stored properties to an appropriate initial value by the time the instance is created, either by assigning a default value as part of the declaration, or in an initialiser:
struct Fahrenheit {
  var temperature: Double
  // In place of setting this in the init(), we could assign a default value
  // in the declaration
  // var temperature = 32.0

  init() {
    temperature = 32.0
  }
}


//: ### Customising Initialisation

//: Initialisation can be customised using initialisation parameters

struct Celcius {
  var tempInCelcius: Double

  // Initialisers can have argument labels and parameter names, like normal functions
  init(fromFahrenheit fahrenheit: Double) {
    tempInCelcius = (fahrenheit - 32.0) / 1.8
  }
  init(fromKelvin kelvin: Double) {
    tempInCelcius = kelvin - 273.15
  }
}

//: Swift provides an automatic argument label for every parameter if you don't provide one:

struct Colour {
  let red, green, blue: Double

  init(red: Double, green: Double, blue: Double) {
    self.red   = red
    self.green = green
    self.blue  = blue
  }

  init(white: Double) {
    red   = white
    green = white
    blue  = white
  }
}

let magenta = Colour(red: 1.0, green: 0.0, blue: 1.0)
let halfGrey = Colour(white: 0.5)

//: To avoid using an argument label in an initialiser, use an underscore:

extension Celcius {
  init(_ celcius: Double) {
    tempInCelcius = celcius
  }
}

let bodyTemperature = Celcius(37.0)

//: Stored properties that are logically allowed to have no value should be declared as optional types and don't have to be initialised:

struct SurveyQuestion {
  let text: String
  var response: String?
  init(text: String) {
    self.text = text
  }
}

var q1 = SurveyQuestion(text: "Do you like cheese?")
q1.response
q1.response = "Yum, yum, yes I do!"


//: ### Default Initialisers

//: Swift provides a _default initialiser_ for any struct / class that provides default values for all non-optional properties and doesn't provide at least one initialiser itself:

struct PurchaseableItem {
  var name: String?
  var quantity = 1
  var purchased = false

  // If the following initialiser were present, the default init() wouldn't exist
  //  init(quantity: Int, purchased: Bool) {
  //    self.quantity = quantity
  //    self.purchased = purchased
  //  }
}

var blankItem = PurchaseableItem()

//: Structure types also automatically receive a default _memberwise initialiser_ if they don't define their own:
var fish = PurchaseableItem(name: "Fish", quantity: 2, purchased: true)

//: Properties with default values can be missed of the memberwise initialiser
var cheese = PurchaseableItem(name: "Cheese")
cheese.quantity


//: ### Initialiser Delegation for Value Types

//: _Initialiser delegation_ allows one initialiser to call another, to share code.  The mechanics vary between value types (which do not support inheritance) and reference types (which do).

//: Value types can only call initialisers in themselves, so we just use `self.init` to call other initialisers:

struct Size {
  var width = 0.0, height = 0.0
}

struct Point {
  var x = 0.0, y = 0.0
}

struct Rect {
  var origin = Point()
  var size = Size()

  init() {}

  init(origin: Point, size: Size) {
    self.origin = origin
    self.size = size
  }

  init(centre: Point, size: Size) {
    let originX = centre.x - (size.width / 2)
    let originY = centre.y - (size.height / 2)
    self.init(origin: Point(x: originX, y: originY), size: size)
  }
}


//: ### Class Inheritance & Initialisation

/*:
 All of a class's stored properties (including those inherited from superclasses) must be assigned an initial value during initialisation.

 There are two types of initialiser:

 - _designated initialisers_ - the primary initialiser for a class.  They fully initialise all properties introduced by the class, and call an appropriate superclass initialiser to continue initialisation up the class hierarchy.  Every class must have at least one (sometimes by inheriting from a superclass), but generally tend to be few, and they tend to be 'funnel' points.

 - _convenience initialisers_ - secondary, supporting initialisers, which can call a designated initialiser in the same class, with default values (a bit like telescoping constructors in Java).
 */

struct Grade {
  var letter: Character
  var points: Double
  var credits: Double
}

class Person {
  var firstName: String
  var lastName: String
  init(firstName: String, lastName: String) {
    self.firstName = firstName
    self.lastName = lastName
  }
}

class Student: Person {
  var grades: [Grade] = []
  func recordGrade(_ grade: Grade) {
    grades.append(grade)
  }
}

class StudentAthlete: Student {
  var sports: [String]

  // This is the designated initialiser and so must call `super.init()`
  init(firstName: String, lastName: String, sports: [String]) {
    // Phase 1 - initialise stored properties of class
    self.sports = sports

    // We want to give student athletes a pass grade
    let passGrade = Grade(letter: "P", points: 0.0, credits: 0.0)
    // but can't call `self.` until phase 1 is complete
    // recordGrade(passGrade)

    // Phase 1 - delegate up to the superclass to continue initialisation
    super.init(firstName: firstName, lastName: lastName)

    // Now in phase 2, so we can call a method on `self`
    recordGrade(passGrade)
  }

  // This is a convenience initialiser, so must call `self.init()` somewhere.
  convenience init(transfer: StudentAthlete) {
    self.init(firstName: transfer.firstName,
              lastName: transfer.lastName,
              sports: transfer.sports)
  }

}

/*:
 There are three rules for delegating calls between initialisers:

 1. a designated init must call a designated init from its immediate superclass.
 2. a convenience init must call another init _from the same class_.
 3. a convenience init must eventually call a designated init.

 These rules are illustrated below and show how calls 'funnel' up the call stack via designated initialisers, i.e.:

 - designated inits must always delegate up the class hierarchy
 - convenience inits must alwasy delegate across the class hierarchy

 ![Initialiser Delegation 1](initialiserDelegation01.png)

 Here's a more complicated example:

 ![Initialiser Delegation 2](initialiserDelegation02.png)
 */

/*:
 To ensure that all stored properties have initial values, class-initialisation is performed in a two-phase process:

 - *Phase 1:* Each stored property is initalised, from the bottom to the top of the class hierarchy.

 - *Phase 2:* Once initial state for each stored property is established, each class is given the opportunity to customise ts stored properties further, and can access `self`.

 Transition between these phases happens after all stored properties are initialised in the base class of a class hierarchy:

 ![Two Phase Initialisation](twoPhaseInitialisation.png)

 Lots more details [here](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html#ID220)
 */


//: ### Initializer Inheritance & Overriding

//: Subclasses don't inherit superclass initialisers by default, but they _are_ automatically inherited if certain conditions are met (see later).

//: A subclass initialiser that matches a superclass designated initialiser _must_ be declared with `override`:

class Vehicle {
  var numberOfWheels = 0
  var description: String {
    return "\(numberOfWheels) wheel(s)"
  }
}
// `Vehicle` automatically receives a default (designated) initialiser
let vehicle = Vehicle()
vehicle.description

class Bicycle: Vehicle {
  // This requires `override` as it overrides the default designated `init()` in `Vehicle`
  override init() {
    super.init()
    numberOfWheels = 2
  }
}
let bicycle = Bicycle()
bicycle.description

//: Conversely, a subclass initialiser that matches a superclass _convenience_ initialiser must not be declared with `override`.


//: ### Automatic Initialiser Inheritance

/*:
 As mentioned earlier, superclass initialisers _are_ inherited in certain special circumstances:

 - *Rule 1:* If a subclass doesn't define any designated initialisers, it automatically inherits all of its superclass designated initialisers.  `Student` gets `Person`'s designated initialisers this way.

 - *Rule 2:* If a subclass provides an implementation of *all* of its superclass designated initialisers, it automatically inherits all of the superclass convenience initialisers.
 */

//: ### Designated & Convenience Initialisers in Action:

//: ![Initialisers in Action](initialisersInAction.png)

//: Base class `Food` encapsulates the name of a foodstuff, with a name, designated initialiser and convenience initialiser that defaults the `name` property:

class Food: CustomPlaygroundDisplayConvertible {
  var playgroundDescription: Any {
    return "Food: [\(name)]"
  }

  var name: String

  // Designated initialiser - needed because classes don't have a default memberwise initialiser.
  // This doesn't need a `super.init()` call because `Food` is a base class
  init(name: String) {
    self.name = name
  }

  // Convenience initialiser - defaults `name` property by delegating to the designated initialiser:
  convenience init() {
    self.init(name: "Unnamed")
  }

}

Food(name: "Bacon")
Food()

//: `RecipeIngredient` models an ingredient in a cooking recipe.  It introduces a new property `quantity`:
class RecipeIngredient: Food {

  override var playgroundDescription: Any {
    return "RecipeIngredient: [\(name) x \(quantity)]"
  }

  // New property added by this subclass
  var quantity: Int

  // Designated initialiser
  init(name: String, quantity: Int) {
    // Check 1 - initialises own properties before delegating up
    self.quantity = quantity
    // Delegates up to ensure `name` is initialised
    super.init(name: name)
  }

  // Convenience initialiser that overrides `Food`'s designated initialiser.
  // Must be marked with `override` because it has the same signature:
  override convenience init(name: String) {
    // Delegates across to `RecipeIngredient`'s designated initialiser
    self.init(name: name, quantity: 1)
  }
}

// Since `RecipeIngredient` provides implementations of all the
// designated initialisers of `Food`, it inherits the convenience initialiser `Food.init()`
RecipeIngredient()
RecipeIngredient(name: "Bacon")
RecipeIngredient(name: "Eggs", quantity: 6)

//: `ShoppingListItem` automatically inherits all of the designated and convenience initialisers from its superclass

class ShoppingListItem: RecipeIngredient {
  override var playgroundDescription: Any {
    return "ShoppingListItem: [\(name) x \(quantity) \(purchased ? "✅" : "❌")]"
  }
  var purchased = false
}

ShoppingListItem()
ShoppingListItem(name: "Bacon")
ShoppingListItem(name: "Eggs", quantity: 6)


//: ### Failable Initialisers

//: Initialisers can fail and return `nil`, e.g. in the case of invalid data.  They create an `Optional<T>`, where `T` is the type on which they are declared:

struct IntUnderTen {
  let value: Int
  init?(value: Int) {
    guard(value < 10) else { return nil }
    self.value = value
  }
}

IntUnderTen(value: 9)
IntUnderTen(value: 11)

//: Failable initialisers can be used to attempt to initialise an enumeration from its `rawValue`:

enum TemperatureUnit: Character {
  case kelvin = "K", celcius = "C", fahrenheit = "F"
}

TemperatureUnit(rawValue: "C")
TemperatureUnit(rawValue: "X")


//: Initialisation failure propagates across to other failable initialisers.

//: It's possible to override a superclass _failable_ initialiser with a subclass _failable_ initialiser, or override a superclass _failable_ initialiser with a subclass _nonfailable_ initialiser.  Can't override a _nonfailable_ initialiser with a _failable_ initialiser_.

class Document {
  var name: String?
  init() {}
  init?(name: String) {
    if name.isEmpty { return nil }
    self.name = name
  }
}

class AutomaticallyNamedDocument: Document {
  override init() {
    super.init()
    self.name = "[Untitled]"
  }

  // Overrides `Document`'s failable initialiser `init?(name:)` with a nonfailable `init(name:)`
  override init(name: String) {
    super.init()
    if name.isEmpty {
      self.name = "[Untitled]"
    } else {
      self.name = name
    }
  }
}

class UntitledDocument: Document {
  override init() {
    // Delegates to the superclass designated initialiser and force-unwraps the result.
    super.init(name: "[Untitled]")!
  }
}

//: It's also possible to define a failable initialiser that creates an implicitly unwrapped optional instance of the appropriate type, using `init!`.


//: ### Required Initialisers

//: Use the `required` modifier before the definition of a class initialiser to indicate that every subclass of the class must implement the initialiser:

class SomeClass {
  required init() {
    // Initialiser implementation goes here
  }
}

//: You need to mark all overrides of a `required` initialiser with the `required` modifier:
class SomeSubClass: SomeClass {
  required init() {
    // subclass implementation goes here
  }
}

//: But an explicit implementation isn't required if you can satisfy the requirement with an inherited initialiser:
class AnotherSubClass: SomeClass {
  // no `init()` required here, just inherits the one from `SomeClass`
}


//: ### Setting a Default Property Value with a Closure or Function

//: We can use a closure or function to provide customised default values for properties:

class SomeType { }

class MyClass {
  let someProperty: SomeType = {

    // Can't access `self` or other property values from in here, because they haven't been initialised yet.

    // create default value for someProperty and return it
    let someValue = SomeType()
    return someValue
  }()                         // Note the invocation of the closure here
}

//: [Next](@next)
