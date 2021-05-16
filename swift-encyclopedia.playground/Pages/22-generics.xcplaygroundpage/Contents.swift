//: [Previous](@previous)
//: ## [22 - Generics](https://docs.swift.org/swift-book/LanguageGuide/Generics.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 17 - 'Generics'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/17-generics)
 - [Swift Apprentice - Chapter 26 - 'Advanced Protocols & Generics'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/26-advanced-protocols-generics)
 */


//: ### Generic Functions

//: Generic functions work with any type.  The _type parameter_ `T` is given after the function name, and is inferred from the calling context.  Type parameters can have generic names (e.g. `T`, `U`, `V`), or more descriptive ones (e.g. `Key`, `Value`, `Element`) if required:

func swapValues<T>(_ a: inout T, _ b: inout T) {
  let tempA = a
  a = b
  b = tempA
}

// Calling with `Int` values
var a = 1
var b = 2
swapValues(&a, &b)
a
b

// Calling with `String` values
var hello = "Hello"
var world = "World"
swapValues(&hello, &world)
hello
world


//: ### Generic Types

//: In addition to generic functions, whole types can be made generic - e.g. `Dictionary<Key, Value>`:

struct Stack<Element> {
  var items = [Element]()
  mutating func push(_ item: Element) {
    items.append(item)
  }
  mutating func pop() -> Element {
    return items.removeLast()
  }
}

var stackOfStrings = Stack<String>()
stackOfStrings.push("uno")
stackOfStrings.push("dos")
stackOfStrings.push("tres")
stackOfStrings.pop()
stackOfStrings


//: ### Extending a Generic Type

//: When extending a generic type, we don't provide a type parameter list, but can refer to existing type parameters in the type being extended:

extension Stack {
  func peek() -> Element? {
    return items.isEmpty ? nil : items[items.count - 1]
  }
}

stackOfStrings.peek()
stackOfStrings


//: ### Type Constraints

//: We can enforce type constraints on type parameters to ensure they conform to a protocol or inherit from a apecific superclass:

// The `<T: Equatable>` constraint means `T` must conform to `Equatable`:
func findIndex<T: Equatable>(of valueToFind: T, in array: [T]) -> Int? {
  for (index, value) in array.enumerated() {
    // without the `T: Equatable` type constraint, this line fails
    if value == valueToFind {
      return index
    }
  }
  return nil
}

findIndex(of: 9.3, in: [3.14159, 0.1, 25])
findIndex(of: 25, in: [3.14159, 0.1, 25])
findIndex(of: "Bob", in: ["Alice", "Bob", "Charles"])


//: ### Associated Types

//: When defining a protocol, it's useful to declare associated types that give a placeholder name to a type used as part of the protocol.  The actual type to use for that associated type isn't used until the protocol is adopted:

protocol Container {
  // The `associatedtype` allows protocol methods to refer to the `Item` type
  associatedtype Item
  mutating func append(_ item: Item)
  var count: Int { get }
  subscript(i: Int) -> Item { get }
}

//: Given an existing, non-generic implementation...
struct IntStack {
  var items = [Int]()
  mutating func push(_ item: Int) {
    items.append(item)
  }
  mutating func pop() -> Int {
    return items.removeLast()
  }
}

//: ... we can extend to adopt the `Container` protocol
extension IntStack: Container {

  // We can optionally make it clear that the associated type here is an
  // `Int`, but if we leave it out, it's inferred.
  typealias Item = Int
  mutating func append(_ item: Int) {
    self.push(item)
  }
  var count: Int {
    return items.count
  }
  subscript(i: Int) -> Int {
    return items[i]
  }
}

//: Alternatively, we can extend the generic version:
extension Stack: Container {
  typealias Item = Element
  mutating func append(_ item: Element) {
    self.push(item)
  }
  var count: Int {
    return items.count
  }
  subscript(i: Int) -> Element {
    return items[i]
  }
}

//: It's possible to extend an existing type to conform to the protocol.  For example, `Array` already conforms, so we can just add an empty extension:
extension Array: Container { }

//: Type constraints can be added to an associated type in a protocol, to require that conforming types satisfy those constraints.  e.g. to conform to `ContainerOfEquatables`, the container's `Item` type has to conform to `Equatable`:

protocol ContainerOfEquatables {
  associatedtype Item: Equatable
  mutating func append(_ item: Item)
  var count: Int { get }
  subscript(i: Int) -> Item { get }
}

//: A protocol can also appear as part of its own requirements, and associated types can also have generic where clauses (see later):

protocol SuffixableContainer: Container {
  associatedtype Suffix: SuffixableContainer where Suffix.Item == Item
  func suffix(_ size: Int) -> Suffix
}

extension Stack: SuffixableContainer {
  func suffix(_ size: Int) -> Stack {
    var result = Stack()
    for index in (count-size) ..< count {
      result.append(self[index])
    }
    return result
  }
}

var stackOfInts = Stack<Int>()
stackOfInts.push(10)
stackOfInts.push(20)
stackOfInts.push(30)
stackOfInts.suffix(2)



//: ### Generic Where Clauses

//: _Type constraints_ can be used to define requirements on the type parameters associated with a generic function, subscript or type.

//: It can also be useful to define requirements for associated types, by defining a _generic where clause_, that allows us to require that an associated type must conform to a certain protocol, or that certain type parameters and associated types must be the same.

//: For example, the generic where clause below specifies that containers `C1` and `C2` must contain the same `Item` type, which must be `Equatable`:

func allItemsMatch<C1: Container, C2: Container>(_ someContainer: C1, _ anotherContainer: C2) -> Bool
  where C1.Item == C2.Item, C1.Item: Equatable {
    if someContainer.count != anotherContainer.count {
      return false
    }
    for i in 0..<someContainer.count {
      if someContainer[i] != anotherContainer[i] {
        return false
      }
    }
    return true
}

allItemsMatch(stackOfInts, [10, 20, 30])


//: ### Extensions with a Generic Where Clause

//: Generic where clauses can also be used as part of an extension to restrict cases where the methods in the extension are available.  Here, `isTop` is only available for `Stack`s whose elements conform to `Equatable`:

extension Stack where Element: Equatable {
  func isTop(_ item: Element) -> Bool {
    guard let topItem = items.last else { return false }
    return topItem == item
  }
}

stackOfInts.isTop(30)

struct NotEquatable { }

var stackOfNotEquatables = Stack<NotEquatable>()
stackOfNotEquatables.push(NotEquatable())
stackOfNotEquatables.push(NotEquatable())
stackOfNotEquatables.push(NotEquatable())
stackOfNotEquatables.peek()

//: This doesn't compile, since `isTop` isn't available
//stackOfNotEquatables.isTop(//....)


//: ### Contextual Where Clauses

//: It's possible to write a generic where clause as part of a declaration that doesn't have its own generic type constraints, if you're already working in the context of generic types, e.g. on a subscript of a generic type, or a method in an extension to a generic type.

// `Container` is already generic, and has an `Item` associated type:
extension Container {

  // This method is only available where `Item` is an `Int`
  func average() -> Double where Item == Int {
    var sum = 0.0
    for index in 0..<count {
      sum += Double(self[index])
    }
    return sum / Double(count)
  }

  // This method is only available where `Item` conforms to `Equatable`:
  func endsWith(_ item: Item) -> Bool where Item: Equatable {
    return count >= 1 && self[count-1] == item
  }
}

let numbers = [1260, 1200, 98, 37]
numbers.average()
numbers.endsWith(37)

//: As an alternative that doens't use contextual where clauses, we could write two separate extensions, one with each constraint.


//: ### Associated Types with a Generic Where Clause

//: An associated type can also include a generic where clause, e.g. to specify that a container's iterator must iterate over the same type of elements as the container itself:

protocol ContainerWithIterator {
  associatedtype Item
  mutating func append(_ item: Item)
  var count: Int { get }
  subscript(i: Int) -> Item { get }

  associatedtype Iterator: IteratorProtocol where Iterator.Element == Item
  func makeIterator() -> Iterator
}


//: ### Generic Subscripts

//: Subscripts can be generic, and can include generic where clauses, e.g. Adding a subscript to Container that takes a sequence of indices:

extension Container {
  subscript<Indices: Sequence>(indices: Indices) -> [Item]
    where Indices.Iterator.Element == Int {
      var result = [Item]()
      for index in indices {
        result.append(self[index])
      }
      return result
  }
}

stackOfInts[[0, 1]]


//: [Next](@next)
