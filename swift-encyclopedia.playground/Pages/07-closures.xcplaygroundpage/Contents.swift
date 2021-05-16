//: [Previous](@previous)
//: ## [7 - Closures](https://docs.swift.org/swift-book/LanguageGuide/Closures.html)

//: ### Closure Expressions

/*:
 Closures take one of three forms:
 - _Global functions_ are closures that have a name and don't capture values.
 - _Nested functions_ are closures that have a name and can capture values from their enclosing function.
 - _Closure expressions_ are unnamed closures that can capture values from their surrounding context.
 */

//: Example of a _closure expression_ is its use in `sorted(by:)`, which sorts an array of values using a function:
let names = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]

func lexicalOrder(_ s1: String, _ s2: String) -> Bool { s1 < s2 }
names
  .sorted(by: lexicalOrder)

//: The named function can be replaced with an inline closure expression (note the removal of the `return` keyword because the closure body is a single statement:
names
  .sorted(by: { (s1: String, s2: String) -> Bool in return s1 < s2 })

//: Since the closure is passed as an argument, Swift can infer the argument and return types, so these can be missed out, together with the brackets:
names
  .sorted(by: { s1, s2 in return s1 < s2 })

//: Single-expression closures can omit `return` to implicitly return their single expression:
names
  .sorted(by: { s1, s2 in s1 < s2 })

//: Shorthand argument names `$0`, `$1` etc can be used to refer to arguments:
names
  .sorted(by: { $0 < $1 })

//: Finally, the `<` operator on `String` has the correct signature, so we can just do:
names.sorted(by: <)


//: ### Trailing Closures

//: If the closure is passed as the last argument of a functon, _trailing closure_ syntax can be used.  The argument label is omitted and the closure is moved outside the function call parentheses:
names
  .sorted() { $0 < $1 }

//: If the closure is the _only_ argument, the function call parenthese can be omitted completely:
names
  .sorted { $0 < $1 }

//: If a function takes multiple closures, omit the argument label for the first trailing closure, and label the remaining trailing closures:
import Foundation
func download(_ filename: String, from server: String) -> Data? {
  // Implement download here
  return nil
}

func loadPicture(from host: String,
                 completion: (Data) -> Void,
                 onFailure: () -> Void) {
  if let picture = download("photo.jpg", from: host) {
    completion(picture)
  } else {
    onFailure()
  }
}

loadPicture(from: "localhost") { picture in
  print("Downloaded picture - processing")
} onFailure: {
  print("Download failure")
}
print()


//: ### Capturing Values

//: Closures can capture constants and variables from their surrounding context.  They can then refer to and modify the values of them within their body, even if the original scope that defined the constants or variables no longer exists:

func makeIncrementer(forIncrement amount: Int) -> () -> Int {
  var runningTotal = 0
  func incrementer() -> Int {  // Nested function captures `runningTotal` and `amount`
    runningTotal += amount
    return runningTotal
  }
  return incrementer            // Once returned, `runnningTotal` / `amount` go out of scope
}

let incrementByTen = makeIncrementer(forIncrement: 10)
incrementByTen()
incrementByTen()
let incrementBySeven = makeIncrementer(forIncrement: 7)
incrementBySeven()         // `incrementBySeven` and `incrementByTen` have independent state
incrementByTen()


//: ### Functions & Closures as Reference Types

//: `incrementByTen` and `incrementBySeven` are able to to increment their respective `runningTotal` variables because functions and closures are reference types:
let alsoIncrementByTen = incrementByTen
alsoIncrementByTen()
incrementByTen()

//: Since functions and closures are reference types, they share access to any state that they capture:
var counter = 0

let increment = { () -> Int in
  counter += 1
  return counter
}
increment()
increment()
increment()

let copy = increment
copy()
increment()
copy()
increment()



//: ### Escaping Closures

//: A closure is said to _escape_ a function if the closure is passed as an argument to the function, but is called after the function returns (e.g. if it is stored in a variable that's defined outside the function):

var handlers = [() -> Void]()
func addHandler(handler: @escaping () -> Void) {
  handlers.append(handler)
}

func runHandlers() {
  for handler in handlers {
    handler()
  }
}

addHandler { print("Handler One") }
addHandler { print("Handler Two") }
addHandler { print("Handler Three") }
print("All handlers added - ready to call `runHandlers()`")
runHandlers()
print()


//: Escaping closures that refer to `self` need consideration if `self` refers to a class instance, because it's easy to accidentally create a strong reference cycle.  To capture `self` in an escaping closure, either use explicit reference, or declare in the capture list:

func functionWithNonescapingClosure(closure: () -> Void) {
  closure()
}
func functionWithEscapingClosure(closure: @escaping () -> Void) {
  closure()
}

class SomeClass {
  var x = 10
  func doSomething() {
    // functionWithEscapingClosure { x = 100 }            // Compile error
    functionWithEscapingClosure { self.x = 100 }          // Option 1 - Make `self` explicit
    functionWithEscapingClosure { [self] in x = 100 }     // Option 2 - Use capture list

    functionWithNonescapingClosure { self.x = 100 }
    functionWithNonescapingClosure { x = 200 }            // Explicit `self` not required
  }
}

let classInstance = SomeClass()
classInstance.doSomething()
classInstance.x

//: If `self` is an instance of a structure or enumeration, `self` can always be referenced implicitly, but an escaping closure can't capture a mutable reference to a structure or enumeration:

struct SomeStruct {
  var x = 10

  func doSomethingNonMutating() {
    functionWithEscapingClosure { print(x) }              // Implicit `self` reference is fine here
    functionWithEscapingClosure { print(self.x) }         // Explicit `self` reference is fine as well
    functionWithEscapingClosure { [self] in               // ... as is explicit capture list entry
      print(x)
    }
  }

  mutating func doSomethingMutating() {
    // Cannot use implicit or explicit `self` references in mutating function
    // functionWithEscapingClosure { print(x) }
    // functionWithEscapingClosure { print(self.x) }

    // Making the capture explicit in the capture list is ok...
    functionWithEscapingClosure { [self] in print(x) }    // `self` in capture list is fine

    // ... but only if we're just reading the instance, not changing it
    // functionWithEscapingClosure { [self] in x = 200 }

    functionWithNonescapingClosure { x = 100 }
    functionWithNonescapingClosure { self.x = 100 }
    // This doesn't work because `[self]` makes this an immutable capture
    // functionWithNonescapingClosure { [self] in x = 100 }
  }
}

var structInstance = SomeStruct()
structInstance.doSomethingNonMutating()
structInstance.doSomethingMutating()
print()


//: ### Autoclosures

//: An _autoclosure_ is a closure that's automatically created to wrap an expression being passed as an argument to a function.  It takes no arguments and returns the value of the expression that's wrapped inside it.

var customersInLine = ["Chris", "Alex", "Ewa", "Barry", "Daniella"]

func serve(customer customerProvider: () -> String) {
  print("Now serving \(customerProvider())!")
}
customersInLine.count
serve(customer: { customersInLine.remove(at: 0) })
customersInLine.count

//: Note the different in the argument declaration from `serve`, and at the call site:
func autoServe(customer customerProvider: @autoclosure () -> String) {
  print("Now serving \(customerProvider())!")
}
customersInLine.count
autoServe(customer: customersInLine.remove(at: 0))
customersInLine.count

//: [Next](@next)
