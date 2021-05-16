//: [Previous](@previous)
//: ## [25 - Access Control](https://docs.swift.org/swift-book/LanguageGuide/AccessControl.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 18 - 'Access Control, Code Organisation & Testing'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/18-access-control-code-organization-testing)
 */

//: ### Modules and Source Files

/*:
 _Modules_ are single units of code distribution - a framework or application that's built and shipped as a single unit, and can be imported using the `import` statement.

 Each build target (e.g. app bundle or framework) in Xcode is a separate module in Swift.

 A _source file_ is a single Swift source code file within a module.
 */


//: ### Access Levels

/*:
 Swift provides five _access levels_ for entities, relative to the source file and module in which they are declared:

 - _Open access_ and _public access_ enables use within any source file in the same module, and any other module which imports the module in which the entity is defined.  See later for the difference between _open_ and _public_ access.

 - _Internal access_ enables use within any source file in the same module, but not from outside the module.

 - _File-private access_ enables use to its own defining file (including any other entites in the same source file).

 - _Private_ access restricts use to the enclosing declaration and extensions of that declaration in the same file.

 No entity can be defined in terms of another entity that has a lower (i.e. more restrictive) access level), e.g.:

 - A public variable can't be defined as having an internal, file-private or private type.

 - a function can't have a higher access level than its parameter types and return type.
 */

// This initialiser can be accessed because it's declared `public`
let openCounter = OpenCounter()

// This function can be accessed because it's declared `public`
openCounter.increment()

// `internal` entities cannot be accessed from outside the declaring module
// let internalCounter = InternalCounter()


//: ### Custom Types

//: See under `Sources/Counter.swift` for examples of access levels.

//: Being _non-nominal types_, tuples can't have their access level specified explicitly.  The access level for a tuple is the most restrictive access level of all types used in the tuple.

//: The access level for a function is the most restrictive level of the function's parameters and return type.  You must specify the level expclitly as part of the function definition if its calculated level doens't match the default:
class SomeInternalClass { }
private class SomePrivateClass { }

//: So this function needs to be declared `private` or `fileprivate`:
private func someFunction() -> (SomeInternalClass, SomePrivateClass) {
  (SomeInternalClass(), SomePrivateClass())
}

//: Individual cases of an enumeration type get the same access level as the enumeration to which they belong.  The types used for any raw values or associated values must have an access level at least as high as the enumeration's access level:
private enum EnumWithPrivateAssociatedType {
  case one(value: SomePrivateClass)
}


//: ### Subclassing

//: You can subclass any class that can be accessed in the current access context and that's defined in the same module as the subclass, but the subclass can't have a higher access level than the superclass:
class SubclassOfSomeInternalClass: SomeInternalClass { }
private class SubclassOfSomePrivateClass: SomePrivateClass { }

//: You can subclass an `open` class from outside the module, but can only override methods that are also `open`:
class OpenCounterSubclass: OpenCounter {
  // However, we can't override `increment` here, because we're not in the same module
  //  override public func increment(by inc: Int = 10) {
  //    count += inc
  //  }

  // We *can* override an open method
  override open func openIncrement(by inc: Int = 1) {
    super.increment(by: inc)
  }
}

//: You can't subclass a `public` (or more restrictive) class from outside the module:
// class PublicCounterSubclass: PublicCounter { }

let ocs = OpenCounterSubclass()
ocs.openIncrement(by: 2)
ocs.increment(by: 10)
ocs.count


//: ### Constants, Variables, Properties & Subscripts

//: Constant, variables and properties can't be more public than their types.  Subscripts can't be more public than either their index type or return type:
private var privateInstance = SomePrivateClass()

//: Getters and setters automatically receive the same access level as the constant, variable, property or subscript they belong to.

// `TrackedString` is `internal` by default
struct TrackedString {
  // Use `private(set)` to make the setter have `private` access.
  // The getter still has `internal` access
  private(set) var numberOfEdits = 0
  var value: String = "" {
    didSet {
      numberOfEdits += 1
    }
  }
}

var trackedString = TrackedString()
trackedString.numberOfEdits
trackedString.value = "different"
trackedString.numberOfEdits

// Setter is not accessible
// trackedString.numberOfEdits = 10


//: ### Initialisers

//: Custom initialisers can be assigned an access level less than or equal to the type that they initialise.  `required` initialisers must have the same access level as the class to which they belong.

//: Default initalisers have the same access level as the type they initalise, unless that type is `public` (in which case the initialiser is `internal`).

//: Default memberwise initalisers are `private` (`fileprivate`) if any of the structure's stored properties are `private` (`fileprivate`).  As with default initialisers for `public` types, the default memberwise initialiser for `public` structs is `internal`.


//: ### Protocols

//: To assign an explicit access level to a protocol type, do so where the protocol is defined.  All requirements in the protocol have the same access level as the protocol itself:

private protocol PrivateProtocol {
  var privateVar: String { get }
  func privateFunc()
}

public protocol PublicProtocol {
  // Note that these are `public`, unlike for concrete types, where they'd default to `internal`
  var publicVar: String { get }
  func publicFunc()
}

public struct PublicStruct: PublicProtocol {
  // In a conforming `public` type, these need to be explicitly declared `public`
  public var publicVar: String
  public func publicFunc() { }
}


//: ### Extensions

//: You can extend a class, structure or enumeration in any access context in which it's available.  Type members added in an extension have the same default access level as those declared in the original type:
extension PublicStruct {
  func internalFunc() { }   // This is `internal` (extending a `public` struct)
}

//: Alternatively, an extension can be marked with an explicit access-level modifier to set the new default access level for all members in the extension:
private extension PublicStruct {
  func privateFunc() { }    // This is `private` because of the explicit modifier
}

/*:
 Extensions in the same file as the class, structure or enumeration that they extend behave as if the code in the extension had been written as part of the original type declaration:

 - Can declare a private member in the original declaration and access it from extensions in the same file.
 - Can declare a private member in one extension, and access it from another extension in the same file.
 - Can declare a private member in an extension, and access it from the original declaration in the same file.
 */

protocol SomeProtocol {
  func doSomething()
}

struct SomeStruct {
  private var privateVariable = 12
}

extension SomeStruct: SomeProtocol {
  func doSomething() {
    print(privateVariable)
  }
}


//: ### Generics

//: The access level for a generic type or function is the minimum of the access levels of the type / function itself and of any type constraints on its type parameters.


//: [Next](@next)
