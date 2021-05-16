//: [Previous](@previous)
//: ## [17 - Error Handling](https://docs.swift.org/swift-book/LanguageGuide/ErrorHandling.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 21 - 'Error Handling'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/21-error-handling)
 */


//: ### Representing & Throwing Errors

//: Errors are represented by types conforming to the empty `Error` protocol:
enum VendingMachineError: Error {
  case invalidSelection
  case insufficientFunds(coinsNeeded: Int)
  case outOfStock
}

//: _Throwing_ an error indicates that soemthing unexpected had happened and needs to be handled.  Functions that can throw errors have `throws` as part of their signature:

struct Item {
  var price: Int
  var count: Int
}

class VendingMachine {
  var inventory = [
    "Candy Bar" : Item(price: 13, count: 7),
    "Chips"     : Item(price: 10, count: 4),
    "Pretzels"  : Item(price: 7, count: 11)
  ]
  var coinsDeposited = 0

  // This method can throw an error:
  func vend(itemNamed name: String) throws -> Item {
    guard let item = inventory[name] else {
      throw VendingMachineError.invalidSelection
    }

    guard item.count > 0 else {
      throw VendingMachineError.outOfStock
    }

    guard item.price <= coinsDeposited else {
      throw VendingMachineError.insufficientFunds(coinsNeeded: item.price - coinsDeposited)
    }

    coinsDeposited -= item.price
    var newItem = item
    newItem.count -= 1
    inventory[name] = newItem

    print("Dispensing \(item)")
    return item
  }
}


//: ### Handling Errors

/*:
 When and error is thrown, some surrounding code is responsible for handling it, using one of the following four ways:

 - 1 - propagate the error to the code that calls the function.
 - 2 - handle the error using `do-catch`.
 - 3 - convert the error to an optional value, using `try?`.
 - 4 - assert that the error will not occur, using `try!`.

 See the following examples:
 */

//: *Method 1* - propagate the error to the calling code, like `vend(itemNamed:)` does.  Here, `buyFavouriteSnack(person:vendingMachine:)` chooses to continue to propagate the error, by declaring `throws` in its signature:

func buyFavouriteSnack(person: String, vendingMachine: VendingMachine) throws -> Item {

  let favouriteSnacks = [
    "Alice": "Chips",
    "Bob": "Liquorice",
    "Eve": "Pretzels"
  ]

  let snackName = favouriteSnacks[person] ?? "Candy Bar"
  return try vendingMachine.vend(itemNamed: snackName)
}

var vendingMachine = VendingMachine()
vendingMachine.coinsDeposited = 10

// This works fine
try buyFavouriteSnack(person: "Alice", vendingMachine: vendingMachine)
print()

// This would terminate the playground, because there are insufficient funds and the error isn't handled:
// try buyFavouriteSnack(person: "Alice", vendingMachine: vendingMachine)


/*:
 *Method 2* - calling code can use a `do-catch` block to handle various types of error, using the construct:

    do {
      try `expression`
      `statements`
    } catch `pattern1` {
      `statements`
    } catch `pattern2` where `condition` {
      `statements`
    } catch {
      // This clause matches any remaining error and binds the error to `error`
      `statements`
    }

 Note: Multiple errors can be listed in the patterns.
 */

do {
  try buyFavouriteSnack(person: "Alice", vendingMachine: vendingMachine)
} catch VendingMachineError.invalidSelection {
  print("Invalid selection")
} catch VendingMachineError.outOfStock {
  print("Out of stock")
} catch VendingMachineError.insufficientFunds(let coinsNeeded) {
  print("Insufficient funds.  Please insert an additional \(coinsNeeded) coins.")
} catch {
  print("Unknonwn error: \(error)")
}
print()

//: *Method 3* - handle error as an optional value by using `try?` to convert the return to an optional value

// Use `try?` to handle an error by converting it to an optional value
let doesntExist = try? vendingMachine.vend(itemNamed: "Doesn't exist")
let tooExpensive = try? vendingMachine.vend(itemNamed: "Chips")
let pretzels = try? vendingMachine.vend(itemNamed: "Pretzels")

//: *Method 4* - assert that the error will not occur using `try!` to wrap the call in a runtime assertion that it won't error.

vendingMachine.coinsDeposited = 20
let chips = try! vendingMachine.vend(itemNamed: "Chips")
print()
// let candy = try! vendingMachine.vend(itemNamed: "Candy Bar")   // error


//: ### Cleanup Actions

//: Use `defer` to execute code just before execution leaves the current block (like Java's `finally`).  Deferred actions are executed in reverse order of the order they're written:

struct File {
  func readLine() throws -> String? {
    print("Calling File.readLine()")
    return nil
  }
}

func exists(_ filename: String) -> Bool {
  print("Calling exists(filename:\(filename))")
  return true
}

func open(_ filename: String) -> File {
  print("Calling open(filename:\(filename))")
  return File()
}

func close(_ file: File) {
  print("Calling close(file:)")
}

func processFile(filename: String) throws {
  if exists(filename) {
    let file = open(filename)
    defer {
      close(file)
    }
    while let line = try file.readLine() {
      print("Got line \(line)")
      // work with the file
    }
    // close(file) is called here, at the end of the scope.
  }
}

try processFile(filename: "TestFile")
print()


//: ### The `rethrows` Keyword

//: Functions or methods can be declared with the `rethrows` keyword to indicate that they throw an error only if one of its function parameters throws an error.  These _rethrowing_ functions must have at least one `throw`ing function parameter:

enum SomeError: Error { case error }

func perform(times: Int, action: () throws -> ()) rethrows {
  for _ in 1...times {
    try action()
  }
}

perform(times: 4, action: { print("Hi") })
print()

do {
  try perform(times: 5, action: { throw SomeError.error })
} catch {
  print("Got error: \(error)")
}
print()


//: ### Error Handling for Asynchronous Code with `Result`:

/*:
 `do-try-catch` only works for _synchronous code_ - asynchronouse code tends to use the `Result` type, declared in the standard library as:

    enum Result<Success, Failure> where Failure: Error {
      case success(Success)
      case failure(Failure)
    }
 */

//: Firstly, an example of some async code that

import Foundation


/// Logs a message to the console, including whether the code is being executed
/// on the main or a background thread.
/// - Parameter message: The message to be logged
func log(message: String) {
  let thread = Thread.current.isMainThread ? "Main" : "Background"
  print("\(thread) thread: \(message)")
}

/// Adds up the integers from 1 to `upTo` (inclusive).
/// - Parameter range: The upper bound of the range to be added.
/// - Returns: The result of adding the numbers in the range `1...range`.
func addNumbers(upTo range: Int) -> Int {
  log(message: "Adding numbers...")
  return (1...range).reduce(0, +)
}


/// Executes a unit of work on a background queue, then executes another
/// unit of work on the main queue (taking in the result of the first unit of
/// work).
/// - Parameters:
///   - backgroundWork: The unit of work to be performed on the background queue.
///   - mainWork: The unit of work to be performed on the foreground queue once
///               `backgroundWork` has been completed.
func execute<Result>(backgroundWork: @escaping () -> Result,
                     mainWork: @escaping (Result) -> ()) {
  let queue = DispatchQueue(label: "queue")
  queue.async {
    let result = backgroundWork()
    DispatchQueue.main.async {
      mainWork(result)
    }
  }
}

//: Here we're using `execute()` to add the numbers on a background queue, then log the result on the main queue.  Note the use of multiple trailing closure syntax.
execute() { addNumbers(upTo: 100) }
  mainWork: { log(message: "The sum is \($0)") }


//: Here's an example of using `Result` to edit tutorials, by using the `execute()` function defined earlier:


struct Tutorial {
  let title: String
  let author: String
}

enum TutorialError: Error {
  case rejected
}

func feedback(for tutorial: Tutorial) -> Result<String, TutorialError> {
  Bool.random() ? .success("publised") : .failure(.rejected)
}

func edit(_ tutorial: Tutorial) {
  execute() {
    feedback(for: tutorial)
  }
  mainWork: { result in
    switch result {
    case let .success(data):
      print("\(tutorial.title) by \(tutorial.author) was \(data) on the website")
    case let .failure(error):
      print("\(tutorial.title) by \(tutorial.author) was \(error)")
    }
  }
}
let tutorial = Tutorial(title: "What's new in Swift?", author: "Martin")
edit(tutorial)
//: [Next](@next)
