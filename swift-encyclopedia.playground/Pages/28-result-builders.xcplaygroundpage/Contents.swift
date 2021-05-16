//: [Previous](@previous)
//: ## [28 - Result Builders](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html#ID630)

//: ### Introduction & Example Model

//: A _result builder_ is a custom type that adds syntax for creating nested data (e.g. lists, trees) in a declarative way.

protocol Drawable {
  func draw() -> String
}

struct Line: Drawable {
  var elements: [Drawable]
  func draw() -> String {
    elements.map { $0.draw() }.joined(separator: "")
  }
}

struct Text: Drawable {
  var content: String
  init(_ content: String) { self.content = content }
  func draw() -> String { content }
}

struct Space: Drawable {
  func draw() -> String { " " }
}

struct Stars: Drawable {
  var length: Int
  func draw() -> String { String(repeating: "*", count: length) }
}

struct AllCaps: Drawable {
  var content: Drawable
  func draw() -> String { content.draw().uppercased() }
}

let name: String? = "Martin Rist"
let manualDrawing = Line(elements: [
  Stars(length: 3),
  Text("Hello"),
  Space(),
  AllCaps(content: Text((name ?? "World") + "!")),
  Stars(length: 2),
  ])
manualDrawing.draw()

//: The above example can be improved using result builders.


//: ### Defining a Result Builder

//: Define a result builder by adding the `@resultBuilder` attribute to a type declaration that defines how the builder works:

@resultBuilder
struct DrawingBuilder {
  // This method adds support for writing a series of lines in a block of code
  static func buildBlock(_ components: Drawable...) -> Drawable {
    Line(elements: components)
  }
  // This method adds support for `if-else`
  static func buildEither(first: Drawable) -> Drawable {
    first
  }
  // This method adds support for `if-else`
  static func buildEither(second: Drawable) -> Drawable {
    second
  }
}


//: ### Applying a Result Builder

//: We can now apply the `@DrawingBuilder` attribute to a function's parameter, which turns a closure passed to the function into the value that the result builder creates from that closure:

func draw(@DrawingBuilder content: () -> Drawable) -> Drawable {
  content()
}

func caps(@DrawingBuilder content: () -> Drawable) -> Drawable {
  AllCaps(content: content())
}

func makeGreeting(for name: String? = nil) -> Drawable {
  let greeting = draw {
    Stars(length: 3)
    Text("Hello")
    Space()
    caps {
      if let name = name {
        Text(name + "!")
      } else {
        Text("World!")
      }
    }
    Stars(length: 2)
  }
  return greeting
}

let genericGreeting = makeGreeting()
genericGreeting.draw()

let personalGreeting = makeGreeting(for: "Martin")
personalGreeting.draw()


//: ### Supporting `for` Loops

//: To support `for` loops, implement `buildArray(_:)` on the result builder struct:
extension DrawingBuilder {
  static func buildArray(_ components: [Drawable]) -> Drawable {
    Line(elements: components)
  }
}

let manyStars = draw {
  Text("Stars:")
  for length in 1...3 {
    Space()
    Stars(length: length)
  }
}
manyStars.draw()

//: [Next](@next)
