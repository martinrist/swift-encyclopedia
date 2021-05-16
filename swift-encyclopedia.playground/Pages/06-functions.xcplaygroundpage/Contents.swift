//: [Previous](@previous)
//: ## [6 - Functions](https://docs.swift.org/swift-book/LanguageGuide/Functions.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 5 - 'Functions'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/5-functions)
 */

//: ### Defining & Calling Functions
//: Functions are defined used the `func` keyword, followed by the function name, then a number of _paramters_ then an optional _return type_:
func greet(person: String) -> String {
  let greeting = "Hello, \(person)!"
  return greeting
}
func greetAgain(person: String) -> String {
  return "Hello again, \(person)!"
}

//: Calling the function definition is done using the function's name, and _arguments_:
greet(person: "Martin")


//: ### Function Parameters & Return Values
//: Functions without parameters have an empty parameter list:
func sayHelloWorld() -> String {
  return "hello, world"
}
sayHelloWorld()

//: Multiple parameters in the parameter list are separated with commas:
func greet(person: String, alreadyGreeted: Bool) -> String {
  if alreadyGreeted {
    return greetAgain(person: person)
  } else {
    return greet(person: person)
  }
}
greet(person: "Martin", alreadyGreeted: true)

//: Functions don't need to have return values - they may just be called purely for their side-effects:
func printGreeting(person: String) {
  print(greet(person: person))
}
printGreeting(person: "Martin")

//: Functions can return tuples to return multiple values.  If there may be no suitable return value, we can return an optinoal tuple type:
func minMax(array: [Int]) -> (min: Int, max: Int)? {
  if array.isEmpty {
    return nil
  }
  return (array.min()!, array.max()!)
}
let bounds = minMax(array: [1, 2, -20, 3])
bounds?.min
bounds?.max
minMax(array: [])

//: Any function that can be written just as a single `return` line can omit the `return` keyword:
func add(x: Int, y: Int) -> Int { x + y }
add(x: 2, y: 4)

//: Functions that are never destined to return have the uninhabited return type `Never`.  These must call another never-returning function on all code paths:
func noReturn() -> Never {
  fatalError()
}
func infiniteLoop() -> Never {
  while true { }
}


//: ### Argument Labels & Parameter Names
//: Parameters can have an _argument label_ (for external use) and a _parameter name_ for use within the function:
func echo1(argLabel paramName: String) -> String {
  return paramName
}
echo1(argLabel: "Hello echo1!")

//: Missing the argument label specifies it to the same as the parameter name:
func echo2(input: String) -> String {
  return input
}
echo2(input: "Hello echo2!")

//: Use `_` to eliminate the need for an argument label at the call site:
func echo3(_ input: String) -> String {
  return input
}
echo3("Hello echo3!")

//: Default parameter values can be specified at the end of the parameter list:
func echo4(name: String, age: Int = 42) -> String {
  return "Hello \(name), you are \(age) years old"
}
echo4(name: "Martin", age: 45)
echo4(name: "Eric")

//: A _variadic_ paramter accepts zero or more values of a specified type, but specifying `...` after the parameter's type name:
func mean(_ numbers: Double...) -> Double {
  // numbers is a [Double]
  var total: Double = 0
  for number in numbers {
    total += number
  }
  return total / Double(numbers.count)
}
mean(1, 2, 3, 4, 5)

//: Functions can have multiple variadic parameters


//: ### Function Overloading
//: Functions can be declared multiple times with differing numbers / types of parameters, different external parameter names or different return types - this is called _function overloading_:
func multipleOf(multiplier: Int, andValue: Int) -> Int { multiplier * andValue }
func multipleOf(multiplier: Int, and value: Int) -> Int { multiplier * value }
func multipleOf(_ multiplier: Int, and value: Int) -> Int { multiplier * value }
func multipleOf(_ multiplier: Int, _ value: Int) -> Int { multiplier * value }

//: Overloading just on return type is possible, but not recommended because it hurts type inference:
func getValue() -> Int { 31 }
func getValue() -> String { "Hello" }

let intValue: Int = getValue()          // Fails with `ambiguous use` error if no type annotation
let stringValue: String = getValue()



//: ### In-Out Parameters
//: Function parameters are constants by default and can't be changed within the function body.  _In-out Parameters_ are specified using the `inout` keyword before the type and are passed by reference:
func swapInts(_ a: inout Int, _ b: inout Int) {
  let tempA = a
  a = b
  b = tempA
}

//: You can only pass a variable as the argument for an in-out parameter, and need to put an `&` at the call site to indicate that it can be modified by the function:
// swapInts(1, 2)                                 // Compilation error
var a = 1
var b = 2
swapInts(&a, &b)
a
b


//: ### Function Types
//: Every function has a specific _function type_ consisting of the parameter types and return type:
func addInts(_ a: Int, _ b: Int) -> Int { a + b }
type(of: addInts)

func printHelloWorld() { print("hello world") }
type(of: printHelloWorld)

let myFunction: (Int, Int) -> Int = addInts(_:_:)


//: ### Nested Functions
//: Functions can be declared inside other functions, where they are known as _nested functions_:
func chooseStepFunction(backward: Bool) -> (Int) -> Int {
  func stepForward(input: Int) -> Int { return input + 1 }
  func stepBackward(input: Int) -> Int { return input - 1 }

  return backward ? stepBackward : stepForward
}

chooseStepFunction(backward: false)(1)
chooseStepFunction(backward: true)(2)


//: ### Function Comments
//: Functions can have comments on lines starting with `///` formatted in markup.  The markup reference can be found [here](https://developer.apple.com/library/archive/documentation/Xcode/Reference/xcode_markup_formatting_ref).

/// Calculates the average of three values
/// - Parameters:
///   - a: The first value.
///   - b: The second value.
///   - c: The third value.
/// - Returns: The average of the three values.
func calculateAverage(of a: Double, and b: Double, and c: Double) -> Double {
  (a + b + c) / 3
}


//: [Next](@next)
