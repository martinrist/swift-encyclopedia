//: [Previous](@previous)
//: ## [12 - Subscripts & Keypaths](https://docs.swift.org/swift-book/LanguageGuide/Subscripts.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 19 - 'Custom Operators, Subscripts & Keypaths'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/19-custom-operators-subscripts-keypaths)
 */


//: ### Subscript Syntax

//: Subscripts enable querying of instances by writing values in square brackets:

struct TimesTable {
  let multiplier: Int

  subscript(index: Int) -> Int {
    // This is a read-only subscript.  If settable, add `set(newValue)` section
    // As with read-only computed properties `get` can be removed
    get {
      return multiplier * index
    }
//    set(newValue) {
//      // If required add setter code here
//    }
  }
}

let threeTimesTable = TimesTable(multiplier: 3)
threeTimesTable[6]
threeTimesTable[4]

//: ### Subscript Options

//: Subscripts can take any number of input parameters, of any type, and can return a value of any type.  A class or structure can also provide any number of subscript implementations.  The appropriate version will be used based on the parameters provided:

struct Matrix {
  let rows: Int, columns: Int
  var grid: [Double]

  init(rows: Int, columns: Int) {
    self.rows = rows
    self.columns = columns
    grid = Array(repeating: 0.0, count: rows * columns)
  }

  func indexIsValid(row: Int, column: Int) -> Bool {
    return row >= 0 && row < rows && column >= 0 && column < columns
  }

  subscript(row: Int, column: Int) -> Double {
    get {
      assert(indexIsValid(row: row, column: column), "Index out of range")
      return grid[(row * columns) + column]
    }
    set {
      assert(indexIsValid(row: row, column: column), "Index out of range")
      grid[(row & columns) + column] = newValue
    }
  }
}

var matrix = Matrix(rows: 2, columns: 2)
matrix[0, 1] = 1.5
matrix[1, 0] = 3.2

matrix


//: ### Type Subscripts

//: It's also possible to declare subscripts that can be called on types:
enum Planet: Int {
  case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune
  static subscript(n: Int) -> Planet {
    Planet(rawValue: n)!
  }
}
Planet[4]


//: ### Dynamic Member Lookup

//: _Dynamic member lookup_ can be used to provide arbitrary dot syntax to a type.  Mark the type with `@dynamicMemberLookup` and implement `subscript(dynamicMember:)`:

@dynamicMemberLookup
struct Instrument {
  let brand: String
  let year: Int
  private let details: [String: String]

  init(brand: String, year: Int, details: [String: String]) {
    self.brand = brand
    self.year = year
    self.details = details
  }

  // This method is required for `@dynamicMemberLookup`
  subscript(dynamicMember key: String) -> String {
    switch key {
    case "info":
      return "\(brand) made in \(year)."
    default:
      return details[key] ?? ""
    }
  }
}

let instrument = Instrument(brand: "Roland", year: 2019,
                            details: ["type": "acoustic",
                                      "pitch": "C"])

instrument.brand            // Static member lookup
instrument.info             // Dynamic member lookup
instrument.type             // Dynamic member lookup
instrument.noDetails        // Dynamic member lookup


//: ### Keypath Expressions

//: _Keypath expressions_ allow references to properties to be stored as first-class values:

struct Person {
  let name: String
  var age: Int
}

struct Tutorial {
  let title: String
  var author: Person
  let details: (type: String, category: String)
}

let me = Person(name: "Martin", age: 48)
var tutorial = Tutorial(title: "Swift Programming",
                        author: me,
                        details: (type: "Swift", category: "iOS"))

//: Keypaths are constructed using a backslash followed by the path to the property being referenced.  They become a value of type `KeyPath<Root, Value>`:

let titlePath = \Tutorial.title
let authorNamePath = \Tutorial.author.name  // Can be accessed several levels deep
let authorAgePath = \Tutorial.author.age    // This is a `WriteableKeyPath`
let typePath = \Tutorial.details.type       // Reference into tuple

//: `appending(path:)` adds a new `KeyPath` to an existing one:
let authorPath = \Tutorial.author
authorPath.appending(path: \.name)

//: `KeyPath`s can be used to get property values using a subscript:
let authorName = tutorial[keyPath: authorNamePath]

//: `WriteableKeyPath`s can be used to set property values on variables:
tutorial[keyPath: authorAgePath] = 49

//: `KeyPath`s can be combined with dynamic member lookup to add type safety:
struct Point {
  let x, y: Int
}

@dynamicMemberLookup
struct Circle {
  let centre: Point
  let radius: Int
  subscript(dynamicMember keyPath: KeyPath<Point, Int>) -> Int {
    centre[keyPath: keyPath]
  }
}

let circle = Circle(centre: Point(x: 1, y: 2), radius: 1)
circle.x
circle.y
// circle.doesNotCompile

//: [Next](@next)
