//: [Previous](@previous)
//: ## 29 - Pattern Matching

/*:
 See also:
 - [Swift Apprentice - Chapter 20 - 'Pattern Matching'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/20-pattern-matching)
 */

//: ### Basic Pattern Matching

//: Basic `if` and `guard` statements can do pattern matching by using a `case` condition, where the pattern is written first, followed by `=` then the value to be matched to the pattern:

func processUsingIf(point: (x: Int, y: Int, z: Int)) -> String {
  if case (0, 0, 0) = point {
    return "At origin"
  }
  return "Not at origin"
}

func processUsingGuard(point: (x: Int, y: Int, z: Int)) -> String {
  guard case (0, 0, 0) = point else {
    return "Not at origin"
  }
  return "At origin"
}

//: To match multiple patterns, use `switch` with `case`.  Note that it's possible to match against a range of numbers:
func processUsingSwitch(point: (x: Int, y: Int, z: Int)) -> String {
  let closeRange = -2...2
  let midRange = -5...5

  switch point {
  case (0, 0, 0):
    return "At origin"
  case (closeRange, closeRange, closeRange):
    return "Very close to origin"
  case (midRange, midRange, midRange):
    return "Near origin"
  default:
    return "Not near origin"
  }
}

//: A `for` loop goes through a collection of elements.  Use a pattern match as a filter:
let groupSizes = [1, 5, 4, 6, 2, 1, 3]
for case 1 in groupSizes {
  print("Found an individual")
}
print()


//: ### Patterns

//: The _wildcard pattern_ `_` matches any value:
let coordinate = (5, 0, 0)
if case (_, 0, 0) = coordinate {
  print("\(coordinate) is on the x-axis")
}
print()

//: The _value-binding pattern_ matches a value and binds it to a variable (using `var`) or constant (using `let`):
if case (let x, 0, 0) = coordinate {
  print("\(coordinate) is on the x-axis at x = \(x)")
}
print()

//: The `let` / `var` in a value-binding pattern can be moved outside the tuple if required to bind multiple values:
if case let (x, y, 0) = coordinate {
  print("\(coordinate) is on the x-y-plane at (\(x), \(y))")
}
print()

//: The _enumeration case_ pattern matches the value of an enumeration:
enum Direction {
  case north, south, east, west
}

let heading = Direction.north

if case .north = heading {
  print("Heading North!")
}
print()

//: The enumeration case pattern can be combined with the value binding pattern to extract associated values:
enum Organism {
  case plant
  case animal(legs: Int)
}

let pet = Organism.animal(legs: 4)

if case .animal(let legs) = pet {
  print("Your pet has \(legs) legs")
}
print()

//: The _optional pattern_ acts as syntactic sugar for enumeration case patterns involving optional values:
let names: [String?] = ["Michelle", nil, "Brandon", "Christine", nil, "David"]

for case let name? in names {
  print(name)
}
print()

//: The `is` operator can be used in a case condition to match instances to particular types:
let response: [Any] = [15, "George", 2.0]

for element in response {
  switch element {
  case is String:
    print("Found a String")
  default:
    print("Found something else")
  }
}
print()

//: The `as` operator combines the `is` type casting pattern with the value-binding pattern:
for element in response {
  switch element {
  case let text as String:
    print("Found a String: \(text)")
  default:
    print("Found something else")
  }
}
print()


//: ### Advanced Patterns

//: Pattern matches can be further qualified by checking a condition using `where`:
for number in 1...9 {
  switch number {
  case let x where x % 2 == 0:
    print("even")
  default:
    print("odd")
  }
}
print()

//: Multiple cases can be combined with commas, to avoid multiple nested `if` statements.  Bindings in earlier statements are available in later ones:

enum Number {
  case integerValue(Int)
  case doubleValue(Double)
  case booleanValue(Bool)
}

let a = 5
let b = 6
let c: Number? = .integerValue(7)
let d: Number? = .integerValue(8)

if a != b,
   let c = c,
   let d = d,
   case .integerValue(let cValue) = c,
   case .integerValue(let dValue) = d,
   dValue > cValue {
  print("a and b are different")
  print("d is greater than c")
  print("sum: \(a + b + cValue + dValue)")
}
print()

//: [Next](@next)
