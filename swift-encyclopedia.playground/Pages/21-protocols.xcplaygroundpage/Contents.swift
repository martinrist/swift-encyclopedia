//: [Previous](@previous)
//: ## [21 - Protocols](https://docs.swift.org/swift-book/LanguageGuide/Protocols.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 16 - 'Protocols'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/16-protocols)
 - [Swift Apprentice - Chapter 25 - 'Protocol Oriented Programming'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/25-protocol-oriented-programming)
 - [Swift Apprentice - Chapter 26 - 'Advanced Protocols & Generics'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/26-advanced-protocols-generics)
 */


//: ### Protocol Syntax

//: A _protocol_ defines a blueprint of methods, properties, and other requirements.  Protocols can then be _adopted_ by classes, structs or enumerations to provide actual implementations.

protocol SomeProtocol {
  // Protocol definition goes here
}

protocol AnotherProtocol {
  // Protocol definition goes here
}

//: Custom types 'adopt' a protocol, either at declaration-time or by extension:
struct SomeStruct: SomeProtocol { }
extension SomeStruct: AnotherProtocol { }
struct YetAnotherString: SomeProtocol, AnotherProtocol { }

//: A superclass is listed first, before any adopted protocols:
class SomeClass { }
class SomeSubclass: SomeClass, SomeProtocol { }


//: ### Property Requirements

//: Protocols can require conforming types to provide instance or type properties with particular names or types, and whether it's gettable or settable:

protocol ProtocolWithProperties {
  // Property requirements are always declared `var`
  var mustBeSettable: Int { get set }
  // Read-only property requirements miss out `set`
  var doesNotNeedToBeSettable: Int { get }

  // Type properties are always declared as `static`, even though they can be
  // implemented as `class` or `static` by a conforming class:
  static var someTypeProperty: Int { get set }
}

//: Property requirement that are `{ get set }` cannot be fulfilled by constant stored properties or read-only computed properties.  Requirements that are read-only (`{ get }`) can be satisfied with stored or computed properties, and can also be settable in the implemenation:

struct Foo : ProtocolWithProperties {

  // Cannot be declared as `let` or read-only computed property
  var mustBeSettable: Int
  // var mustBeSettable: Int { 42 }

  let doesNotNeedToBeSettable: Int
  static var someTypeProperty: Int = 42
}

//: Example of a `FullyNamed` protocol, adopted by two structs:

protocol FullyNamed {
  var fullName: String { get }
}

// `Person` conforms to `FullyNamed` via a stored property (which is also settable)
struct Programmer: FullyNamed {
  var fullName: String
}
let me = Programmer(fullName: "Martin")

// `Startship` conforms to `FullyNamed` via a computed property
struct Starship: FullyNamed {
  var prefix: String?
  var name: String
  var fullName: String {
    return (prefix != nil ? prefix! + " ": "") + name
  }
}
let ncc1701 = Starship(prefix: "USS", name: "Enterprise")
ncc1701.fullName


//: ### Method Requirements

//: Protocols can specify instance and type methods to be implemented by conforming types:

protocol RandomNumberGenerator {
  // Functions are declared without the body
  func random() -> Double
}

class LinearCongruentialGenerator: RandomNumberGenerator {
  var lastRandom = 42.0
  let m = 139968.0
  let a = 3877.0
  let c = 29573.0

  func random() -> Double {
    lastRandom = ((lastRandom * a + c).truncatingRemainder(dividingBy: m))
    return lastRandom / m
  }
}

let generator = LinearCongruentialGenerator()
generator.random()
generator.random()


//: Mark a method `mutating` in the protocol if it needs to mutate `self`.  This allows the method to be written as `mutating` if the protocol is adopted by a struct or enum:
protocol Togglable {
  mutating func toggle()
}

enum OnOffSwitch: Togglable {
  case off, on

  mutating func toggle() {
    switch self {
    case .off:
      self = .on
    case .on:
      self = .off
    }
  }
}

var lightSwitch = OnOffSwitch.off
lightSwitch.toggle()


//: ### Initialiser Requirements

//: Protocols can require specific initialisers to be implemented by conforming types:
protocol ProtocolWithInit {
  init(someParameter: Int)
}

//: Protocol initialiser requirements can be implemented on a class either as a designated or convenience initialiser.  Must be denoted `required` if the class is not `final` to enforce all subclasses to also provide an initialiser:
class SomeClassWithInit: ProtocolWithInit {
  required init(someParameter: Int) {
    // init implementation here
  }
}


//: ### Protocols As Types

/*:
 Protocols are first-class types, so can be used in all the expected places:

 - As a parameter type or function / method / initialiser return type.
 - As the type of a constant, variable or property.
 - As the type of items in an array, dictionary, or other container.

 Using a protocol as a type is sometimes called an _existential type_ (i.e. 'there exists a type _T_ such that _T_ conforms to the protocol'):
 */

class Dice {
  let sides: Int
  let generator: RandomNumberGenerator      // Type of a property

  // Type of a method argument
  init(sides: Int, generator: RandomNumberGenerator) {
    self.sides = sides
    self.generator = generator
  }

  func roll() -> Int {
    return Int(generator.random() * Double(sides)) + 1
  }
}

let d20 = Dice(sides: 20, generator: LinearCongruentialGenerator())
d20.roll()
d20.roll()


//: ### Delegation

//: _Delegation_ allows a class or struct to hand off (delegate) responsibilities to an instance of another type, by defining a protocol for those responsibilites:

/// Protocol that can be adopted by any game that involves dice
protocol DiceGame {
  var dice: Dice { get }
  func play()
}

//: To track progress of a game, we create a `DiceGameDelegate` protocol.  `: AnyObject` means that it can only be adopted by reference types, which allows use of `weak var` to prevent strong reference cycles:

protocol DiceGameDelegate : AnyObject {
  func gameDidStart(_ game: DiceGame)
  func game(_ game: DiceGame,
            didStartNewTurnWithDiceRoll diceRoll: Int)
  func gameDidEnd(_ game: DiceGame)
}

class SnakesAndLadders: DiceGame {
  let finalSquare = 25
  let dice = Dice(sides: 6, generator: LinearCongruentialGenerator())
  var square = 0
  var board: [Int]

  init() {
    board = Array(repeating: 0, count: finalSquare + 1)
    board[03] = +08; board[06] = +11; board[09] = +09; board[10] = +02;
    board[14] = -10; board[19] = -11; board[22] = -02; board[24] = -08;
  }

  // This needs to be a weak ref to avoid reference cycles
  weak var delegate: DiceGameDelegate?

  func play() {
    square = 0
    delegate?.gameDidStart(self)

    gameLoop: while square != finalSquare {
      let diceRoll = dice.roll()
      delegate?.game(self, didStartNewTurnWithDiceRoll: diceRoll)
      switch square + diceRoll {
      case finalSquare:
        break gameLoop
      case let newSquare where newSquare > finalSquare:
        continue gameLoop
      default:
        square += diceRoll
        square += board[square]
      }
    }

    delegate?.gameDidEnd(self)
  }
}

//: We can now create a class to conform to `DiceGameDelegate` to track progress

class DiceGameTracker: DiceGameDelegate {
  var numberOfTurns = 0

  func gameDidStart(_ game: DiceGame) {
    numberOfTurns = 0
    if game is SnakesAndLadders {
      print("Started a new game of Snakes & Ladders")
    }
    print("The game is using a \(game.dice.sides)-sided dice")
  }

  func game(_ game: DiceGame, didStartNewTurnWithDiceRoll diceRoll: Int) {
    numberOfTurns += 1
    print("Rolled a \(diceRoll)")
  }

  func gameDidEnd(_ game: DiceGame) {
    print("The game lasted for \(numberOfTurns) turns")
  }
}

let tracker = DiceGameTracker()
let game = SnakesAndLadders()
game.delegate = tracker
print("About to play game")
game.play()
print()


//: Adding Protocol Conformance with Extensions

//: Existing types can be extended to adopt a new protocol via extensions:

protocol TextRepresentable {
  var textualDescription: String { get }
}

extension Dice: TextRepresentable {
  var textualDescription: String {
    return "A \(sides)-sided dice"
  }
}

let d12 = Dice(sides: 12, generator: LinearCongruentialGenerator())
d12.textualDescription

//: This can even be the case for extending existing classes

import Foundation

extension URL: TextRepresentable {
  var textualDescription: String {
    return "URL with absolute value \(absoluteURL)"
  }
}

let url = URL(string: "./foo/bar/blort.jpg")!
url.textualDescription

//: A generic type may be able to satisfy a protcol only under certain conditions (e.g. when the generic parameter conforms to the protocol).  This is called _conditional conformance_:

extension Array: TextRepresentable where Element: TextRepresentable {
  var textualDescription: String {
    let itemsAsText = self.map {
      $0.textualDescription
    }
    return "[" + itemsAsText.joined(separator: ", ") + "]"
  }
}

let myDice = [d20, d12]
myDice.textualDescription

//: If a type already conforms to all of the requirements of a protocol but hasn't yet stated that it conforms to the protocol, an empty extension can be used:
struct Hamster {
  var name: String
  var textualDescription: String { "A hamster named \(name)" }
}
extension Hamster: TextRepresentable {}


//: ### Adopting Protocols with Synthesized Implementations

//: Swift can generate protocol conformance for `Equatable`, `Hashable` and `Comparable` in certain cases.

/*:
 `Equatable` / `Hashable` can be synthesized for:

 - Structures that only have stored properties conforming to `Equatable` / `Hashable`.
 - Enumerations that only have associated types conforming to `Equatable` / `Hashable`.
 - Enumerations without associated types.
 */

struct Vector3D: Equatable, Hashable {
  var x = 0.0, y = 0.0, z = 0.0
}
let twoThreeFour = Vector3D(x: 2, y: 3, z: 4)
let alsoTwoThreeFour = Vector3D(x: 2, y: 3, z: 4)
twoThreeFour == alsoTwoThreeFour

let setOfVectors = Set<Vector3D>([Vector3D(x: 1, y: 2, z: 3),
                                  Vector3D(x: 4, y: 5, z: 6)])

//: `Comparable` can be synthesized for enumerations without a raw value or with associated types conforming to `Comparable`.
enum SkillLevel: Comparable {
  case beginner
  case intermediate
  case expert(stars: Int)
}

SkillLevel.beginner < SkillLevel.intermediate
SkillLevel.intermediate < SkillLevel.expert(stars: 1)
SkillLevel.expert(stars: 1) < SkillLevel.expert(stars: 2)
SkillLevel.expert(stars: 5) == SkillLevel.expert(stars: 5)


//: ### Protocol Inheritance

//: A protocol can inherit other protocols and add new requirements:

protocol PrettyTextRepresentable: TextRepresentable {
  var prettyTextualDescription: String { get }
}

//: Anything that adopts `PrettyTextRepresentable` must also satisfy requirements of `TextRepresentable`
extension Dice: PrettyTextRepresentable {
  var prettyTextualDescription: String {
    return "[Prettified] \(textualDescription)"
  }
}
d20.prettyTextualDescription


//: ### Protocol Composition

//: Can require a type to conform to multiple protocols using _protocol composition_:

protocol Named {
  var name: String { get }
}

protocol Aged {
  var age: Int { get }
}

struct Person: Named, Aged {
  var name: String
  var age: Int
}

//: `Named & Aged` here means than the parameter must conform to both protocols:

func wishHappyBirthday(to celebrator: Named & Aged) {
  print("Happy birthday, \(celebrator.name), you're \(celebrator.age)!\n")
}

let person = Person(name: "Martin", age: 45)
wishHappyBirthday(to: person)


//: Checking for Protocol Conformance

//: We can use `is` and `as` to test / cast protocol conformance in the same way as we did earlier in ['Type Casting'](18-type-casting) for subclasses:

person is Named
person is Aged
person is TextRepresentable

person as? Named
person as? TextRepresentable


//: ### Optional Protocol Requirements

//: Can define optional requirements for a protocol that help interoperate with Objective-C.  Both the protocol and the optional requirement must be marked with `@objc`:

@objc protocol CounterDataSource {
  @objc optional func increment(forCount count: Int) -> Int
  @objc optional var fixedIncrement: Int { get }
}

class Counter {
  var count = 0
  var dataSource: CounterDataSource?

  func increment() {
    if let amount = dataSource?.increment?(forCount: count) {
      count += amount
    } else if let amount = dataSource?.fixedIncrement {
      count += amount
    }
  }
}

class ThreeSource: CounterDataSource {
  let fixedIncrement = 3
}

var counter = Counter()
counter.dataSource = ThreeSource()

for _ in 1...4 {
  counter.increment()
  print(counter.count)
}


//: ### Protocol Extensions

//: We can extend protocols to provide method, init, subscript and computed property implementations to conforming types.

//: Adding methods with implementations can be used to provide additional methods, based on methods in the protocol:

extension RandomNumberGenerator {
  func randomBool() -> Bool {
    return random() > 0.5
  }
}
LinearCongruentialGenerator().randomBool()

//: Can also be used to provide _default_ default implementations that can be used if not overridden:
extension PrettyTextRepresentable {
  var prettyTextualDescription: String {
    return textualDescription
  }
}

extension Int: TextRepresentable {
  var textualDescription: String { "\(self)" }
}

extension Int: PrettyTextRepresentable { }
42.prettyTextualDescription

//: When defining protocol extensions, it is possible to add a constraint - called a _generic `where` clause_ so that the extension only applies in certain cases:

extension Collection where Element: Equatable {
  func allEqual() -> Bool {
    for element in self {
      if element != self.first {
        return false
      }
    }
    return true
  }
}

[1, 2, 3, 4].allEqual()
[1, 1, 1, 1].allEqual()
["a", "b", "a", "b"].allEqual()
["a", "a", "a", "a"].allEqual()

let diceArray = [d12, d20]
// This doesn't work unless we make Dice conform to Equatable
// diceArray.allEqual()


//: Note that if a type defines a method or property in a protocol extension without declaring it in the protocol itself, calls to the method are dispatched statically - i.e. the actual implementation called is selected at compile-time:

protocol WinLoss {
  var wins: Int { get }
  var losses: Int { get }

  // `winningPercentage` isn't in the main protocol
  // var winningPercentage: Double { get }
}

extension WinLoss {
  // This is declared in the extension, rather than the protocol, so calls to it are dispatched statically
  var winningPercentage: Double {
    Double(wins) / Double(wins + losses)
  }
}

struct CricketRecord: WinLoss {
  var wins: Int
  var losses: Int
  var draws: Int

  var winningPercentage: Double {
    Double(wins) / Double(wins + losses + draws)
  }
}

let miamiTuples = CricketRecord(wins: 8, losses: 7, draws: 1)
let winLoss: WinLoss = miamiTuples

miamiTuples.winningPercentage           // Calls the implementation in `CricketRecord`
winLoss.winningPercentage               // Calls the implementation in `WinLoss`



//: ### Existential vs Non-Existential Protocols

//: An _existential type_ is a concrete type accessed through a protocol:
protocol Pet {
  var name: String { get }
}

struct Cat: Pet {
  var name: String
}

//: Here `Pet` is an _existential type_ - an abstract concept, a protocol, that refers to a concrete type (the `Cat` struct) that exists:
var somePet: Pet = Cat(name: "Whiskers")

//: If a protocol has associated types, it's not possible to use it as an existential type
protocol HungryPet {
  associatedtype Food
  var name: String { get }
  func eat(food: Food)
}

extension Cat: HungryPet {
  typealias Food = String
  func eat(food: String) { }
}

// var someHungryPet: HungryPet = Cat(name: "Mr Nibbles")   // Compile error

//: ### Non-existential Protocols


//: [Next](@next)
