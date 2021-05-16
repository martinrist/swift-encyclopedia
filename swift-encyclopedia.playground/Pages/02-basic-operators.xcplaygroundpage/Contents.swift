//: [Previous](@previous)
//: ## [2 - Basic Operators](https://docs.swift.org/swift-book/LanguageGuide/BasicOperators.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 1 - 'Expressions, Variables & Constants'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/1-expressions-variables-constants)
 */

//: ### Assignment Operator

//: The _assignment_ operator (`=`) initialises or updates a value with another value:
let b = 10
var a = 5
a = b

let (x, y) = (1, 2)
x
y


//: ### Arithmetic Operators

//: The four standard arithmetic operators (`+`, `-`, `*`, `/`) are defined for all numeric types:
1 + 2
5 - 3
2 * 3
10.0 / 2.5

//: The addition operator is also overloaded for `String` concatenation:
"Hello, " + "world"

//: The _remainder_ operator (`%`) returns the remainder when its first operand is divided by its second:
9 % 4
-9 % 4

//: The _unary minus_ operator (`-`) toggles the sign of its operand:
let three = 3
let minusThree = -three
let plusThree = -minusThree

//: The _unary plus_ operator (`+`) returns its operand unchanged:
let minusSix = -6
let alsoMinusSix = +minusSix


//: ### Compound Assignment Operators

//: _Compound assignment_ operators (e.g. `+=`) combine assignment with another operation:
var i = 1
i += 2


//: ### Comparison Operators

//: Comparison operators make a comparison between their two operands, and return a `Bool` result:
1 == 1
2 != 1
2 > 1
1 < 2
1 >= 1
2 <= 1

//: Tuples can be compared memberwise if they have the same type and number of values.  Comparison of individual corresponding values is done left-to-right:
(1, "zebra") < (2, "apple")      // true because 1 < 2
(3, "apple") < (3, "bird")       // true because 3 == 3 and apple < bird
(4, "dog") == (4, "dog")


//: ### Ternary Conditional Operator

//: The _ternary conditional_ operator (`? :`) returns its second or third operand, according to whether its first evalues to true / false:
let contentHeight = 40
let hasHeader = true
let rowHeight = contentHeight + (hasHeader ? 50 : 20)


//: ### `nil`-Coalescing Operator

//: The _`nil`-coalescing_ operator (`??`) unwraps an optional if it contains a value, or falls back to the provided default:
let defaultColourName = "red"
var userDefinedColourName: String?
var colourNameToUse = userDefinedColourName ?? defaultColourName
userDefinedColourName = "green"
colourNameToUse = userDefinedColourName ?? defaultColourName


//: ### Range Operators

//: The _closed range_ operator (`...`) defines a range that runs between the two endpoints and includes both of them:
(1...5).forEach { print($0) }         // Includes 1 and 5

//: The _half-open range_ operator (`..<`) is similar, but doesn't include the second endpoint:
(1..<5).forEach { print($0) }

//: The range operators have corresponding _one-sided_ versions that continue as far as poosible in one direction:
let names = ["Anna", "Alex", "Brian", "Jack"]
names[2...]
names[...2]


//: ### Logical Operators

//: The _logical NOT_ operator (`!`) inverts a `Bool` value:
!(1 == 2)

let allowedEntry = false
if !allowedEntry {
  print("ACCESS DENIED")
}

//: The _logical AND_ operator (`&&`) returns `true` iff both of its operands are `true`:
let enteredDoorCode = true
let passedRetinaScan = false
if enteredDoorCode && passedRetinaScan {
  print("Welcome!")
} else {
  print("ACCESS DENIED")
}

//: The _logical OR_ operator (`||`) returns `true` iff either or both of its operands are `true`:
let hasDoorKey = false
let knowsOverridePassword = true
if hasDoorKey && knowsOverridePassword {
  print("Welcome!")
} else {
  print("ACCESS DENIED")
}

//: Both `&&` and `||` are _short-circuiting_ operators - they don't evaluate their second operand if not required.

//: [Next](@next)
