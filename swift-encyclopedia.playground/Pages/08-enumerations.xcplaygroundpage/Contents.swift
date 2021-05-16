//: [Previous](@previous)
//: ## [8 - Enumerations](https://docs.swift.org/swift-book/LanguageGuide/Enumerations.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 15 - 'Enumerations'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/15-enumerations)
 */

//: ### Enumeration Syntax

//: Enumeration cases are denoted with the `case` keyword, either with each case on a separate line, or comma-separated:
enum CompassPoint {
  case north
  case south
  case east
  case west
}

enum Planet {
  case mercury, venus, earth, mars, jupiter, saturn, uranus, neptune
}


//: ### Matching in `switch` Statements

//: Matching on enumeration cases in `switch` statements works as expected.  The enumeration cases are used to determine switch exhaustivity:
let somePlanet = Planet.earth
switch somePlanet {
case .earth:
  print("Mostly harmess")
default:
  print("Not a safe place for humans")
}
print()


//: ### Iterating over Enumeration Cases

//: Enumerations that conform to `CaseIterable` have an `allCases` property which can be used to iterate over all the enumeration's cases:
enum Beverage: CaseIterable {
  case coffee, tea, juice
}
Beverage.allCases

for beverage in Beverage.allCases {
  print(beverage)
}
print()


//: ### Associated Values

//: Additional values of other types can be stored against each case, in order to implement sum types / discriminated unions / tagged unions / variants:
enum Barcode {
  case upc(Int, Int, Int, Int)
  case qrCode(String)
}

var productBarcode = Barcode.upc(8, 85909, 51226, 8)

//: Values of one case can change to the other case if defined using `var`:
productBarcode = .qrCode("ABCDEFGHIJKLMN")

//: Associated values can be extracted in `switch` cases, using either `let` or `var`:
switch productBarcode {
case let .upc(numberSystem, manufacturer, product, check):
  // `let` here binds all the associated values as constants
  print("UPC: \(numberSystem), \(manufacturer), \(product), \(check).")

case .qrCode(let productCode):
  // Alternatively, we can bind values individually
  print("QR code: \(productCode)")
}
print()


//: ### Raw Values

//: Specifying a type after the enumeration name specifies the _raw type_ of the enumeration, and allows _raw values_ to be specified for each case:
enum ASCIIControlCharacter: Character {
  case tab = "\t"
  case lineFeed = "\n"
  case carriageReturn = "\r"
}

//: For some types, raw values can be implicitly assigned if not provided:
enum NewCompassPoint: String {
  case north, south, east, west
}
NewCompassPoint.north.rawValue

enum NewPlanet: Int {
  case mercury = 1, venus, earth, mars, jupiter, saturn, uranus, neptune
}
NewPlanet.venus.rawValue

//: Enumerations with raw-values have a failable initialiser to create an instance of the enum from the raw value:
let maybeUranus = NewPlanet(rawValue: 7)
let plutoIsntAPlanet = NewPlanet(rawValue: 9)


//: ### Recursive Enumerations

//: Recursive enumerations have an instance of the enumeration itself as an associated value of one or more cases.  This is specified using `indirect` to add a layer of indirection:
enum Expression {
  case number(Int)
  indirect case addition(Expression, Expression)
  indirect case multiplication(Expression, Expression)
}

let five = Expression.number(5)
let four = Expression.number(4)
let sum = Expression.addition(five, four)
let product = Expression.multiplication(sum, Expression.number(2))

func eval(_ expression: Expression) -> Int {
  switch expression {
  case let .number(value):
    return value
  case let .addition(left, right):
    return eval(left) + eval(right)
  case let .multiplication(left, right):
    return eval(left) * eval(right)
  }
}

eval(product)

//: [Next](@next)
