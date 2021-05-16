//: [Previous](@previous)
//: ## [5 - Control Flow](https://docs.swift.org/swift-book/LanguageGuide/ControlFlow.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 3 - 'Basic Control Flow'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/3-basic-control-flow)
 - [Swift Apprentice - Chapter 4 - 'Advanced Control Flow'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/4-advanced-control-flow)
 - [Swift Apprentice - Chapter 20 - 'Pattern Matching'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/20-pattern-matching)
 */


//: ### `for-in` Loops

//: `for-in` loops iterate over a sequence or numeric range:
let names = ["Alice", "Bob", "Charles", "David"]
for name in names {
  print("Hello \(name)!")
}
print()

let numberOfLegs = ["spider": 8, "ant": 6, "cat": 4, "human": 2]
for (animal, legs) in numberOfLegs {
  print("\(animal)s have \(legs) legs")
}
print()

for index in 1...5 {
  print(index)
}
print()

//: Unneeded iteration variables can be denoted with `_`:
for _ in 1...5 {
  print("Hello!")
}
print()


//: ## `while` and `repeat-while` Loops

//: First form of the `while` loop evaluates the condition at the start of each pass, so may not execute at all:
var i = 0
while i < 5 {
  print(i)
  i = i + 1
}
print()

//: The second form - the `repeat-while` loop evaluates the condition at the end, and therefore always executes at least once.  It''s more like the traditional `do..while` loop from other languages:
var j = 0
repeat {
  print(j)
  j = j + 1
} while j < 10
print()


//: ## `if-else` Statements

//: The `if-else` statement is the standard conditional statement, with multiple (optional) clauses separated by `else if` and a final (optional) `else` clause:
let score = 20
if score <= 5 {
  print("Atrocious")
} else if score <= 10 {
  print("Bad")
} else if score <= 20 {
  print("Average")
} else if score <= 30 {
  print("Good")
} else {
  print("Excellent")
}
print()


//: ### `switch` Statements

//: The `switch` statement compares a value against one or more values of the same type:
switch score {
case 0:                    // Single case
  print("Worst score")     // No fallthrough to next case
case 1, 2, 3, 4, 5:        // Multiple cases, comma-separated
  print("Atrocious")
case 6...10:               // Interval matching using a closed range
  print("Bad")
case 11..<21:              // Interval matching using a half-open range
  print("Average")
case 666:                  // Case bodies cannot be empty -
  break                    // use `break` to break out
default:
  print("No idea!")        // switch must be exhaustive
}
print()

//: Tuples can be used to test multiple values in cases
let somePoint = (1, 1)

switch somePoint {
case (0, 0):
  print("At the origin")
case (_, 0):
  print("On the x-axis")
case (0, _):
  print("On the y-axis")
case (-2...2, -2...2):
  print("In the box")
default:
  print("Somewhere else")
}
print()

//: _Value bindings_ can be used to refer to matched values in the `case` block.  `where` clauses can additionally test those values to constrain the case more
let anotherPoint = (2, 3)

switch anotherPoint {
case (let x, 0):
  print("On the x-axis with an x value of \(x)")
case (0, let y):
  print("On the y-axis with a y value of \(y)")
case let (x, y) where x == y:
  print("On the line x = y")
case let (x, y):
  print("Another point - (\(x), \(y))")
}
print()

//: The `fallthrough` keyword can be used to opt into traditional Java- and C-style behaviour if required:
let integerToDescribe = 5
var description = "The number \(integerToDescribe) is"

switch integerToDescribe {
case 2, 3, 5, 7, 11, 13, 17, 19:
  description += " a prime number and also"
  fallthrough
default:
  description += " an integer"
}
print(description)
print()


//: ### Control Transfer Statements

//: The `continue` statement tells a loop to stop and start again at the beginning of the next iteration:
let puzzleInput = "great minds think alike"
var puzzleOutput = ""
let charactersToRemove: [Character] = ["a", "e", "i", "o", "u", " "]
for character in puzzleInput {
  if charactersToRemove.contains(character) {
    continue
  }
  puzzleOutput.append(character)
}
print(puzzleOutput)
print()

//: The `break` statement ends execution of an entire control flow statement (e.g. a `switch` or loop) immediately:
let numberSymbol: Character = "三"  // Chinese symbol for the number 3
var possibleIntegerValue: Int?
switch numberSymbol {
case "1", "١", "一", "๑":
  possibleIntegerValue = 1
case "2", "٢", "二", "๒":
  possibleIntegerValue = 2
case "3", "٣", "三", "๓":
  possibleIntegerValue = 3
case "4", "٤", "四", "๔":
  possibleIntegerValue = 4
default:
  break
}
if let integerValue = possibleIntegerValue {
  print("The integer value of \(numberSymbol) is \(integerValue).")
} else {
  print("An integer value couldn't be found for \(numberSymbol).")
}
print()

//: Loop statements can be labelled and the labels used in the target of control transfer statements:
outer: for i in 1...5 {
  inner: for j in 1...5 {
    if j > i {
      continue outer
    }
    print("(\(i), \(j))")
  }
}
print()

//: ### Early Exit

//: `guard` statements evaluate a condition.  If not met, the code in the `else` block is executed to terminate the function early:
func greet(person: [String: String]) {
  guard let name = person["name"] else {
    print("Not sure who you are, but hello anyway!")
    return
  }
  print("Hello \(name)!")
}

greet(person: ["name": "John"])
greet(person: ["nom": "David"])


//: ### API Availability Checks

//: _Availability conditions_ can be used to detect the presence of APIs:
if #available(iOS 10, macOS 10.2, *) {
  // Use iOS 10 APIs on iOS and macOS 10.12 APIs on macOS
} else {
  // Fall back to earlier APIs
}

//: [Next](@next)
