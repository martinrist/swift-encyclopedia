//: [Previous](@previous)
//: ## [26 - Advanced Operators](https://docs.swift.org/swift-book/LanguageGuide/AdvancedOperators.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 19 - 'Custom Operators, Subscripts & Keypaths'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/19-custom-operators-subscripts-keypaths)
 */

//: ### Bitwise Operators

//: _Bitwise operators_ enable manipulation of individual raw data bits within a data structure.

//: Bitwise NOT - `~`:
let initialBits: UInt8 = 0b00001111
let invertedBits = ~initialBits
String(invertedBits, radix: 2)

//: Bitwise AND - `&`:
let firstSixBits: UInt8 = 0b11111100
let lastSixBits: UInt8  = 0b00111111
let middleFourBits = firstSixBits & lastSixBits
String(middleFourBits, radix: 2)

//: Bitwise OR - `|`:
let someBits: UInt8 = 0b10110010
let moreBits: UInt8 = 0b01011110
let combinedBits = someBits | moreBits
String(combinedBits, radix: 2)

//: Bitwise XOR - `^`:
let firstBits: UInt8 = 0b00010100
let otherBits: UInt8 = 0b00000101
let outputBits = firstBits ^ otherBits
String(outputBits, radix: 2)

//: Bitwise Left / Right Shift - `<<` / `>>`:
let shiftBits: UInt8 = 0b100
String(shiftBits << 1, radix: 2)
String(shiftBits << 2, radix: 2)
String(shiftBits << 5, radix: 2)
String(shiftBits << 6, radix: 2)

String(shiftBits >> 1, radix: 2)
String(shiftBits >> 2, radix: 2)
String(shiftBits >> 3, radix: 2)

/*:
 Left- or right-shifting of unsigned integers does a _logical shift_:

 - Existing bits are moved left / right.
 - Bits moved beyond the bounds of the integer's storage are discarded.
 - Zeros are inserted in the spaces left behind:

 ![Unsigned Bit Shifts](bitshiftUnsigned.png)

 Signed integers are stored as their _two's complement_ representation:

 ![Signed Integer - +4](bitshiftSignedFour.png)

 ![Signed Integer - -4](bitshiftSignedMinusFour.png)

 Left-shifting signed integers behaves the same as for unsigned integers.  For right-shifting, an _arithmetic shift_ is performed:

 - Any empty bits on the left are filled with the sign bit, rather than with zero:

 ![Signed Right Shift](bitshiftSigned.png)
*/


//: ### Overflow Operators

//: Swift reports an error rather than overflowing by default:
var potentialOverflow = Int16.max
// potentialOverflow += 1             // Runtime error

//: There are overflowing versions of addition, subtraction and multiplication - `&+` / `&-` / `&*`:

let unsignedOverflow = UInt8.max
unsignedOverflow &+ 1

let unsignedUnderflow = UInt8.min
unsignedUnderflow &- 1


//: ### Operator Precedence & Associativity

//: Swift has standard precedence & associativity rules, e.g.:
2 + 3 % 4 * 5


//: ### Operator Methods

//: Classes and structs can overload existing operators by providing their own implementations:

struct Vector2D: CustomStringConvertible {
  var x = 0.0, y = 0.0
  var description: String { return "[\(x), \(y)]" }
}

extension Vector2D {
  // Implement the binary infix operator `+` as a `static` func
  static func + (left: Vector2D, right: Vector2D) -> Vector2D {
    return Vector2D(x: left.x + right.x, y: left.y + right.y)
  }
}

//: We can now apply `+` to two `Vector2D`'s:
let v1 = Vector2D(x: 3.0, y: 1.0)
let v2 = Vector2D(x: 2.0, y: 4.0)
v1 + v2

//: Operators defined as above are _infix_ by default.  To make them _prefix_ or _postfix_ operators, add the `prefix` or `postfix` modifier to the function signature:
extension Vector2D {
  static prefix func - (vector: Vector2D) -> Vector2D {
    return Vector2D(x: -vector.x, y: -vector.y)
  }
}
-v1

//: To implement compound assignment operators, e.g. +=, mark the first parameter as `inout`:

extension Vector2D {
  static func += (left: inout Vector2D, right: Vector2D) {
    left = left + right
  }
}

var original = Vector2D(x: 1.0, y: 2.0)
let vectorToAdd = Vector2D(x: 3.0, y: 4.0)
original += vectorToAdd


//: ### Custom Operators

//: As well as overloading existing operators, new custom operators can be defined.  They are declared at a global level using the `operator` keyword:

prefix operator +++

//: To implement the operator, add a type method to implementing types:

extension Vector2D {
  static prefix func +++ (vector: inout Vector2D) -> Vector2D {
    vector += vector
    return vector
  }
}

var toBeDoubled = Vector2D(x: 1, y: 4)
let afterDoubling = +++toBeDoubled

//: Custom infix operators belong to precedence groups which specify their precedence relative to other infix operators, together with the operator's associativity:

infix operator +-: AdditionPrecedence
extension Vector2D {
  static func +- (left: Vector2D, right: Vector2D) -> Vector2D {
    return Vector2D(x: left.x + right.x, y: left.y - right.y)
  }
}
let firstVector = Vector2D(x: 1, y: 2)
let secondVector = Vector2D(x: 3, y: 4)
let plusMinusVector = firstVector +- secondVector

//: Custom precedence groups can be created that can specify associativity and precedence relative to other precedence groups.  e.g. for an exponentiation operator `**`:

precedencegroup ExponentiationPrecedence {
  associativity: right
  higherThan: MultiplicationPrecedence
}

infix operator **: ExponentiationPrecedence

func **<T: BinaryInteger>(base: T, power: Int) -> T {
  precondition(power >= 2)
  var result = base
  for _ in 2...power {
    result *= base
  }
  return result
}

2 ** 5
2 * 2 ** 3 ** 2
2 * (2 ** (3 ** 2))
//: [Next](@next)
