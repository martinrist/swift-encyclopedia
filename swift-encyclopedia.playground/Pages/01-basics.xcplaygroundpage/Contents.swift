//: [Previous](@previous)
//: ## [1 - The Basics](https://docs.swift.org/swift-book/LanguageGuide/TheBasics.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 1 - 'Expressions, Variables & Constants'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/1-expressions-variables-constants)
 - [Swift Apprentice - Chapter 2 - 'Types & Operations'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/2-types-operations)
 - [Swift Apprentice - Chapter 6 - 'Optionals'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/6-optionals)
 */


//: ### Constants & Variables

//: Constants declared before use, using `let`, variables using `var`:
let maximumNumberOfLoginAttempts = 10
var currentLoginAttempt = 0

//: Declare multiple constants / variables by comma-separation:
var x = 0.0, y = 0.0, z = 0.0

//: Declarations can be annotated with types if this can't be inferred:
var welcomeMessage: String
let errorMessage = "Incorrect password"   // Type inferred from literal

//: Variables can be changed, constants can't:
var friendlyWelcome = "Hello"
friendlyWelcome = "Bonjour"

let languageName = "Swift"
// languageName = "Swift++"   // Compile error


//: ### Comments

//: Comments can be single-line (`//`) or multi-line (`/* ... */`):
// This is a single line comment

/* This is also a comment
 but is written across multiple lines.
 */


//: ### Semicolons

//: Semicolons at the end of lines are optional, but required to separate multiple statements on a single line:
let cat = "😸"; print(cat)
print("🐶");                  // Optional here


//: ### Integers

//: Swift has plain `Int` type (same size as current platform's native word size), together with signed- and unsigned 8-, 16-, 32- and 64-bit variants:
let zero = 0
let minusOne = -1
let two: UInt = 2
let eight: UInt8 = 8
let minusFour: Int64 = -4

//: Use `Int` when you can to aid consistency and interoperability.  Only use other-sized `Int` variants when they're specifically needed to match explicitly-sized data from external sources,


//: ### Floating-Point Numbers

//: _Floating-point_ numbers with a fractional component are represented using `Double` (64-bit) or `Float` (32-bit):
let roughlyPi = 3.1415926                // `Double`
let roughlyPiFloat: Float = 3.1415926    // `Float`


//: ### Type Safety & Type Inference

//: Types are checked at compile time and incorrect assignments cause compile errors:
// let anInteger: Int = "not an integer"   // Compile error

//: Types can often be inferred, eliminating the need for explicit type annotations:
let fortyTwo = 42           // Type `Int` inferred
let pi = 3.1415926          // Type `Double` inferred


//: ### Numeric Literals

//: Integer literals can be written as:
let decimalInteger = 17
let binaryInteger = 0b10001
let octalInteger = 0o21
let hexadecimalInteger = 0x11

//: Floating-point literals can be written as:
let decimalDouble = 12.1875
let exponentDouble = 1.21875e1        // `e` represents the exponent
let hexadecimalDouble = 0xC.3p0       // `p` represents the exponent

//: Extra zeroes and underscores can be used to aid readability:
let paddedDouble = 000123.456
let oneMillion = 1_000_000
let justOverOneMillion = 1_000_000.000_000_1


//: ### Numeric Type Conversion

//: Because numeric types can store different ranges of values, we need to opt in to numeric conversion on a case-by-case basis:
let twoThousand: UInt16 = 2_000
let one: UInt8 = 1
// let twoThousandAndOne = twoThousand + one       // Compile error
let twoThousandAndOne = twoThousand + UInt16(one)  // Conversion required

//: Conversion between integer and floating-point numeric types must also be explicit:
let three = 3
let pointOneFourOneFiveNine = 0.14159
// let piBySumming = three + pointOneFourOneFiveNine      // Compile error
let piBySumming = Double(three) + pointOneFourOneFiveNine // Conversion required

//: Floating-point values are truncated when initialising integer values:
Int(4.75)
Int(-3.9)


//: ### Type Aliases

//: Type aliases define an alternative name for a type, which is interchangeable (not a separate type):
typealias AudioSample = UInt16
var sample1: AudioSample = 1
sample1 = UInt16(4)


//: ### Booleans

//: Logical truth / falsity represented using values of type `Bool`:
let orangesAreOrange = true
let turnipsAreDelicious = false


//: ### Tuples
//: Tuples are non-nominal types that group multiple values into a single value:
let http404Error = (404, "Not Found")    // : (Int, String)

//: Tuple contents can be destructured into component parts, using `_` to skip unwanted parts:
let (statusCode, statusMessage) = http404Error
statusCode
statusMessage

let (justTheCode, _) = http404Error
justTheCode

//: Alternatively, access element values using zero-based indices
http404Error.0
http404Error.1

//: Tuple elements can also be named, but this doesn't prevent index-based access:
let http200Status = (statusCode: 200, description: "OK")
http200Status.statusCode
http200Status.1

//: Tuple literals without labels are type-compatible with the labelled version, but if the labels are given, they must be correct:
typealias Status = (statusCode: Int, description: String)
let http400Error: Status = (400, "Bad Request")

// let http401Error: Status = (wibble: 401, wobble: "Unauthorised")


//: ### Optionals

//: Optionals indicate the potential absence of a value, using the type `Optional<T>`, abbreviated to `T?`:
let convertedNumber = Int("123")          // convertedNumber: Int?
let cantBeConverted = Int("foo")

//: Optionals without a value contain the value `nil`:
var serverResponseCode: Int? = 404
serverResponseCode = nil

//: _Optional Binding_ can be used to bind a name to the value in an optional, iff it contains a value:
var possibleNumber = "123"
if let actualNumber = Int(possibleNumber) {
  print("The string \"\(possibleNumber)\" has an integer value of \(actualNumber)")
} else {
  print("The string \"\(possibleNumber)\" couldn't be converted to an integer")
}

//: _Force unwrapping_ using `!` will extract the value from an optional, but will crash if the optional contains `nil`:
Int("123")!
//Int("foo")!         // Runtime crash

//: Sometimes it is clear from the program structure that an optional will always have a value after set.  These can be declared as _implicitly unwrapped optionals_.  They won't need unwrapping, but will crash if referenced and they don't contain a value:
let possibleString: String? = "An optinoal string."
let forcedString: String = possibleString!   // Requires force-unwrapping

let assumedString: String! = "An implicitly unwrapped optional string."
let implicitString: String = assumedString   // No need for `!`


//: ### Error Handling

//: Error handling allows us to respond to error conditions that may be encoutered during execution.

//: Functions that can throw errors have `throws` in their signature:
func canThrowAnError() throws {
  // this function may or may not throw an error
}

//: Errors are propagated out of their current scope (created with `do`) until they are handled by a `catch` clause:
do {
  try canThrowAnError()
  // no error thrown
} catch {
  // an error was thrown
}


//: ### Assertions & Preconditions

/*:
 Assertions and preconditions are used for non-recoverable, unexpected error conditions, and terminate the running program if they're not valid:
 - _Assertions_ are checked only in debug builds and are used to find mistakes and incorrect assumptions during development.  In production builds the condition inside assertions isn't evaluated so they don't affect production performance.
 - _Preconditions_ are checked in both debug and production builds.
 */

//let age = -3      // If uncommented, this will cause the assertion to fail.
let age = 3
assert(age >= 0, "A person's age can't be less than zero.")

//: `assertionFailure(_:file: file:)` indicates that an assertion has failed:
if age > 10 {
  print("You can ride the roller-coaster or the ferris wheel.")
} else if age >= 0 {
  print("You can ride the ferris wheel.")
} else {
  assertionFailure("A person's age can't be less than zero.")
}

func element(at index: Int, of array: [String]) -> String {
  precondition(index >= 0 , "Index must be non-negative.")
  return array[index]
}

element(at: 1, of: ["foo", "bar", "blort"])
// element(at: -1, of: ["foo", "bar", "blort"])   // precondition failed

//: `precondition`s are always assumed to be true if compiled in unchecked mode (`-Ounchecked`), but `fatalError(_:file:line:)` always causes an error:

func notImplementedYet() {
  fatalError()
}

// notImplementedYet()     // Causes error regardless of compilation settings

//: [Next](@next)

