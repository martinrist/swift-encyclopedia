//: [Previous](@previous)
//: ## [3 - Strings & Characters](https://docs.swift.org/swift-book/LanguageGuide/StringsAndCharacters.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 9 - 'Strings'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/9-strings)
 */

//: ### String Literals

//: String literals are sequences of characters within `"` marks:
let someString = "Some string literal value"

//: String literals can span multiple lines using `"""`.  The amount of whitespace before the closing `"""` determines the indent level:
let linesWithIndentation = """
  This line doesn't begin with whitespace.

      This line begins with four spaces, and is preceded with a blank line.

  This line uses the backslash to create a soft-wrap, where the line goes \
  to aid formatting, but doesn't include a real newline character.
  """

//: String literals can contain certain special characters:
let nullCharacter = "\0"
let literalBackslash = "\\"
let horizontalTab = "\t"
let lineFeed = "\n"
let carriageReturn = "\r"
let literalDoubleQuote = "\""
let literalSingleQuote = "\'"
let unicodeScalar = "\u{1F496}"

//: _Extended string delimiters_ can be used by wrapping quotation marks in one or more `#` characters.
let extendedLiteral = #"This is a string literal"#
let anotherExtendedLiteral = ###"This is also a string literal"###
let foo = ###"Special characters like \###nneed to match the number of #'s"###

//: ### Strings as Value Types

//: `String` instances are value types, so they are copied when assigned to another constant or variable, or passed to a method or function:
var original = "original value"
let copy = original
original = "changed value"
copy


//: ### Working with Characters

//: Individual `Character` values in a `String` can be retrieved by iterating:
for character in "Dog! 🐶" {
  print(character)
}

//: Individual `Character` instances can be created from a single-character, by using a type annotation:
let exclamationMark: Character = "!"

//: `String` values can be concatenated using `+`, and `Character`s can be appended to a `String` using `append(_:)`:
var lookOverThere = "look over " + "there"
lookOverThere.append(exclamationMark)


//: ### String Interpolation

//: String interpolation allows values to be easily included in string literals using `\(expr)`:
let multiplier = 3
let message = "\(multiplier) times 2.5 is \(Double(multiplier) * 2.5)"

//: To use interpolation inside extended delimiters, match the number of `#` signs surrounding the outer double quotes:
#"This isn't \(interpolated)"#

let interpolated = "interpolated"
#"This is \#(interpolated)"#


//: ### Unicode

//: Swift `String`s are build from _Unicode scalar values_, e.g. `U+0061 - LATIN SMALL LETTER A`.  Every instance of a `Character` represents an _extended grapheme cluster_ - a sequence of one or more Unicode scalars that produce a single character on combination:

let eActute: Character = "\u{E9}"                 // é
let combiningAcuteAccent: Character = "\u{301}"   // COMBINING ACUTE ACCENT, U+0301
let combinedEAcute: Character = "\u{65}\u{301}"   // e followed by U+0301
eActute == combinedEAcute                         // Note that these are equal

//: The `count` property of a `String` gives its length, but this may not change when adding combining characters:
var cafe = "cafe"
cafe.count
cafe += "\u{301}"       // COMBINING ACUTE ACCENT, U+0301
cafe.count

//: When written to storage, Unicode scalars are encoded in various _encoding forms_ to break the scalars down into 8-bit units:
let dogString = "‼🐶"          // DOUBLE EXCLAMATION MARK (U+203C) + DOG FACE (U+1F436)
dogString.utf8.forEach { print("\($0) ", terminator: "") }
print()
dogString.utf16.forEach { print("\($0) ", terminator: "") }
print()
dogString.unicodeScalars.forEach { print("\($0.value) ", terminator: "") }
print()


//: ### Accessing & Modifying Strings

//: Because each character in a string may consist of multiple Unicode scalars, it's not possible to index into `String`s using integers.  Instead we use `String.Index`:
let greeting = "Guten Tag!"
let startIndex = greeting.startIndex
greeting[startIndex]
greeting[greeting.index(after: startIndex)]
greeting[greeting.index(startIndex, offsetBy: 4)]

let endIndex = greeting.endIndex
// greeting[endIndex]                  // Runtime error: String index out of bounds
greeting[greeting.index(before: endIndex)]

greeting.indices.forEach { idx in
  print("\(greeting[idx]) ", terminator: "")
}

//: Inserting and removing characters can be done with `insert(_:at:)` and `remove(_:at:)`.  `remove(_:at:)` returns the removed character:
var welcome = "hello"
welcome.insert("!", at: welcome.endIndex)
welcome.insert(contentsOf: " there", at: welcome.index(before: welcome.endIndex))
welcome.remove(at: welcome.index(before: welcome.endIndex))
welcome

let removalRange = welcome.index(welcome.endIndex, offsetBy: -6) ..< welcome.endIndex
welcome.removeSubrange(removalRange)


//: ### Substrings
//: Substrings (from subscripts or methods like `prefix(_:)` return an instance of `Substring`, which can reuse portinos of the original `String`.  As a result, they're typically used for short-term storage and only have a subset of `String` methods:

let helloWorld = "Hello, world!"
let index = helloWorld.firstIndex(of: ",") ?? helloWorld.endIndex
var beginning = helloWorld[..<index]
let newString = String(beginning)


//: [Next](@next)
