//: [Previous](@previous)
//: ## [9 - Structures & Classes](https://docs.swift.org/swift-book/LanguageGuide/ClassesAndStructures.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 10 - 'Structures'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/10-structures)
 - [Swift Apprentice - Chapter 13 - 'Classes'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/13-classes)
 - [Swift Apprentice - Chapter 24 - 'Valid Types & Reference Types'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/24-value-types-reference-types)
 */


//: ### Definition Syntax
//: Structures and classes have similar definition syntax, using the `struct` vs `class` keyword:

struct Resolution {
  var width = 0
  var height = 0
}

class VideoMode {
  var resolution = Resolution()
  var interlaced = false
  var frameRate = 0.0
  var name: String?
}

//: Instances are created using the same syntax for structures and classes:
let someResolution = Resolution()       // Default values assigned
let someVideoMode = VideoMode()         // Default values assigned, nil for name

//: Structures have default memberwise initialisers for all properties, whereas classes do not:
let vgaRez = Resolution(width: 640, height: 480)
let defaultHeightRez = Resolution(width: 320)         // `height` has the default value
defaultHeightRez.height
// let vgaMode = VideoMode(resolution: vgaRez, interlaced: false)


//: ### Structures and Enumerations are Value Types

//: Both structures and enumerations are _value types_, which means their value is _copied_ when assigned to a variable or constant, or passed to a function:

let hd = Resolution(width: 1920, height: 1080)
var cinema = hd                                     // Creates a new instance
cinema.width = 2048
hd.width                                            // Changing `cinema`'s properties doesn't affect `hd`


//: ### Classes are Reference Types
//: Classes are _reference types_, which means that the constant / variable defines a _reference_ to the data, rather than the data itself.  Updating an instance via one instance changes the shared instance:

let tenEighty = VideoMode()
tenEighty.resolution = hd
tenEighty.interlaced = true
tenEighty.name = "1080i"
tenEighty.frameRate = 25.0

let alsoTenEighty = tenEighty                         // This alias points to the same instance as `tenEighty`

alsoTenEighty.name = "Also 1080i"
alsoTenEighty.name
tenEighty.name                                        // Changing via one reference affects the alias

//: Identical instances can be tested using the `===` and `!==` operators:
tenEighty === alsoTenEighty
tenEighty !== alsoTenEighty


//: ### Stack vs Heap Storage

/*:
 Structures / enumerations and classes differ according to where they're stored in the computer's memory:

 - Structure / enumeration values are stored on the _stack_, unless they're properties of a class instance in which case they're stored on the _heap_ together with the class instance data.  Stack storage stores anything on the immediate thread of execution.  Functions allocate stack variables on entry and deallocate them on exit.

 - Class instance data is stored on the _heap_.  This gives them a more flexible and dynamic lifetime.  Data stored on the heap isn't automatically destroyed (since it might be shared).

 When a class instance is created, memory is allocated from the heap, then the address of that memory is stored in a named variable (the reference) on the stack.
 */


//: ### When to Prefer Value or Reference Semantics

//: Value semantics are appropriate for representing inert, descriptive data - e.g. numbers, strings and physical quantities, or collections thereof.

//: Reference semantics are suitable for representing distinct items in your program or in the world, e.g. objects or memory buffers that change over time and coordinate with other objects.  The key here is that each of these objects has a distinct identity, even if all their properties are the same.


//: 

//: [Next](@next)
