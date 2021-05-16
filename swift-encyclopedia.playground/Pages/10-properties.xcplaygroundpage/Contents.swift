//: [Previous](@previous)
//: ## [10 - Properties](https://docs.swift.org/swift-book/LanguageGuide/Properties.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 11 - 'Properties'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/11-properties)
 */


//: ### Stored Properties

//: Stored properties are constants or variables that are stored as part of an instance of a class or structure:

struct FixedLengthRange {
  var firstValue: Int             // Variable stored property
  let length: Int                 // Constant stored property
}

var rangeOfThree = FixedLengthRange(firstValue: 0, length: 3)
rangeOfThree.firstValue = 6       // `firstValue` can be changed
// rangeOfThree.length = 2        // `length` cannot be changed

//: Variable stored properties of constant structure instances cannot be changed, as they are value types:
let rangeOfFour = FixedLengthRange(firstValue: 0, length: 4)
//rangeOfFour.firstValue = 3      // `firstValue` cannot be changed here, because `rangeOfFour` is a constant struct

//: Variable stored properties of constant class instances _can_ be changed, since its only the reference that is constant, not the contents:
class VideoMode {
  var interlaced = false
  var frameRate = 0.0
  let name: String? = "default"
}

let defaultMode = VideoMode()
defaultMode.frameRate = 60            // variable property can be changed
//defaultMode.name = "new name"       // constant property can't be changed

//: Lazy stored properties only have their initial value calculated when they are first used - can be useful for expensive initialisation:
class LazyClass {
  lazy var lazyString: String = {
    print("Lazy initialising lazyString")
    return "lazy"
  }()
}

print("Before initialising LazyClass")
let lazyClass = LazyClass()
print("After initialising LazyClass")
print("Before accessing lazyString")
print("lazyString = \(lazyClass.lazyString)")
print("After accessing lazyString")
print()


//: ### Computed Properties

//: Computed properties provide a getter and (optional) setter to retrieve and set other properties and values directly:

struct Point {
  var x = 0.0, y = 0.0
}

struct Size {
  var width = 0.0, height = 0.0
}

struct Rect {
  var origin = Point()
  var size = Size()

  // `centre` is the computed property - it must be declared with `var`
  var centre: Point {

    // Getter is called when `centre` is accessed
    // Note omission of `return` for a single-expression getter body:
    get {
      Point(x: origin.x + (size.width) / 2,
            y: origin.y + (size.height) / 2)
    }

    // Setter is called when `centre` is set
    // `newCentre` is the new value - `newValue` is used if not specified:
    set(newCentre) {
      origin.x = newCentre.x - (size.width / 2)
      origin.y = newCentre.y - (size.height / 2)
    }
  }
}

//: Read-only computed properties have no setter - these miss out the `set` clause completely, and can optionally miss out `get`:
struct Cuboid {
  var width = 0.0, height = 0.0, depth = 0.0
  var volume: Double {
    return width * height * depth
  }
}

var cuboid = Cuboid(width: 10, height: 5, depth: 2)
cuboid.volume


//: ### Property Observers

//: `willSet` and `didSet` are called immediately before / after a new property value is stored

class StepCounter {
  var totalSteps: Int = 0 {
    willSet(newTotalSteps) {
      // Argument name defaults to `newValue` if not specified
      print("About to set totalSteps to \(newTotalSteps)")
    }

    didSet(oldTotalSteps) {
      // Argument name defaults to `oldValue` if not specified
      if totalSteps > oldTotalSteps {
        print("Added \(totalSteps - oldTotalSteps) steps")
      }
    }
  }
}

let stepCounter = StepCounter()
stepCounter.totalSteps = 200
stepCounter.totalSteps = 360


//: ### Property Wrappers

//: _Property wrappers_ allow extracting common logic that we want to run on all several properties.  They are defined using a type that defines a `wrappedValue` property and has the `@propertyWrapper` declaration attribute:

@propertyWrapper
struct TwelveOrLess {
  private var number: Int = 0
  var wrappedValue: Int {
    get { return number }
    set { number = min(newValue, 12) }
  }
}

struct SmallRectangle {
  @TwelveOrLess var height: Int
  @TwelveOrLess var width: Int
}

var rectangle = SmallRectangle()
rectangle.height
rectangle.height = 10
rectangle.height
rectangle.height = 24
rectangle.height

//: The compiler synthesises the following code for the `SmallRectangle` example above:

struct SmallRectangleSynth {
  private var _height = TwelveOrLess()
  private var _width = TwelveOrLess()
  var height: Int {
    get { _height.wrappedValue }
    set { _height.wrappedValue = newValue }
  }
  var width: Int {
    get { return _width.wrappedValue }
    set { _width.wrappedValue = newValue }
  }
}

var rectangleSynth = SmallRectangleSynth()
rectangleSynth.width
rectangleSynth.width = 10
rectangleSynth.width
rectangleSynth.width = 24
rectangleSynth.width

//: We can allow properties declared with initial values, and support wrapper configuration by providing different initalisers in the wrapper definition type:

@propertyWrapper
struct SmallNumber {
  private var number: Int
  private var maximum: Int

  var wrappedValue: Int {
    get { number }
    set { number = min(newValue, maximum) }
  }

  // This is called when applying the wrapper to a property with no initial value
  init() {
    maximum = 12
    number = 0
  }

  // This is called when applying the wrapper to a property with an initial value
  init(wrappedValue: Int) {
    maximum = 12
    number = min(wrappedValue, maximum)
  }

  // This is used when the wrapper attribute is followed by property wrapper arguments
  init(wrappedValue: Int, maximum: Int) {
    self.maximum = maximum
    number = min(wrappedValue, maximum)
  }

}

struct ZeroRectangle {
  // These use `init()`
  @SmallNumber var height: Int
  @SmallNumber var width: Int
}

var zeroRectangle = ZeroRectangle()
(zeroRectangle.height, zeroRectangle.width)

struct UnitRectangle {
  // These use `init(wrappedValue:)`
  @SmallNumber var height: Int = 1
  @SmallNumber var width: Int = 1
}

var unitRectangle = UnitRectangle()
(unitRectangle.height, unitRectangle.width)

struct NarrowRectangle {
  // These use `init(wrappedValue:maximum:)`
  @SmallNumber(wrappedValue: 2, maximum: 5) var height: Int
  @SmallNumber(wrappedValue: 3, maximum: 4) var width: Int
}

let narrowRectangle = NarrowRectangle()
(narrowRectangle.height, narrowRectangle.width)

struct MixedRectangle {
  @SmallNumber var height: Int = 1                 // Uses `init(wrappedValue:)`
  @SmallNumber(maximum: 9) var width: Int = 2      // Uses `init(wrappedValue:maximum:)`
}

var mixedRectangle = MixedRectangle()
(mixedRectangle.height, mixedRectangle.width)

//: In addition to a _wrapped value_, a proeprty wrapper can expose a _projected value_, whose name is the same as the wrapped value, prefixed with `$`:

@propertyWrapper
struct SmallNumberWithProjection {
  private var number: Int
  var projectedValue: Bool  // Did the number get clamped to 12?
  init() {
    self.number = 0
    self.projectedValue = false
  }
  var wrappedValue: Int {
    get { number }
    set {
      if (newValue > 12) {
        number = 12
        projectedValue = true
      } else {
        number = newValue
        projectedValue = false
      }
    }
  }
}

struct StructureWithProjection {
  @SmallNumberWithProjection var someNumber: Int
}
var structure = StructureWithProjection()

structure.someNumber = 4
structure.$someNumber

structure.someNumber = 20
structure.someNumber
structure.$someNumber


//: ### Type Properties

//: _Type properties_ belong to a type, rather than an instance of the type:
struct SomeStructure {
  static var storedTypeProperty = "Some value."
  static var computedTypeProperty: Int {
    return 1
  }
}

//: For classes, type properties are declared using `class` to allow overriding:

class SomeClass {
  static var storedTypeProperty = "Some value."
  static var computedTypeProperty: Int {
    return 27
  }
  class var overrideableComputedTypeProperty: Int {
    return 107
  }
}

class SomeSubClass : SomeClass {
  override class var overrideableComputedTypeProperty: Int {
    return 108
  }
}

//: Querying and setting type properties works as for instance properties, using the type:
SomeStructure.storedTypeProperty
SomeClass.overrideableComputedTypeProperty
SomeSubClass.overrideableComputedTypeProperty

//: [Next](@next)
