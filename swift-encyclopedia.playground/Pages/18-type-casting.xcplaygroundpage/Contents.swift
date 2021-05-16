//: [Previous](@previous)
//: ## [18 - Type Casting](https://docs.swift.org/swift-book/LanguageGuide/TypeCasting.html)


//: ### Example Class Hierarchy
//: This is the example hierarchy we'll use for this section:
class MediaItem {
  var name: String
  init(name: String) {
    self.name = name
  }
}

class Movie: MediaItem {
  var director: String
  init(name: String, director: String) {
    self.director = director
    super.init(name: name)
  }
}

class Song: MediaItem {
  var artist: String
  init(name: String, artist: String) {
    self.artist = artist
    super.init(name: name)
  }
}

let library = [
  Movie(name: "Casablanca", director: "Michael Curtiz"),
  Song(name: "Blue Suede Shoes", artist: "Elvis Presley"),
  Movie(name: "Citizen Kane", director: "Orson Welles"),
  Song(name: "The One And Only", artist: "Chesney Hawkes"),
  Song(name: "Never Gonna Give You Up", artist: "Rick Astley")
]

//: Note that `library` is inferred as type `[MediaItem]`, even though its contents are actually concrete `Movie`s or `Song`s:
type(of: library)


//: ### Checking Type

//: The `is` operator can be used to check whether an instance is of a particular type:
library[0] is Movie
library[1] is Movie

//: Can also use the `type(of:)` function to get a type
type(of: library[0])


//: ### Downcasting

//: The `as?` operator can be used to perform a conditional downcast, which can fail, returning `nil`:
library[0] as? Movie
library[0] as? Song

//: The forced type cast operator `as!` does the same, but throws a runtime error if the downcast fails:
library[0] as! Movie
// library[0] as! Song      // Runtime error


//: ### Type Casting for `Any` and `AnyObject`

/*:
 There are two special types for working with unspecified types:
 - `Any` - any type at all, including function types
 - `AnyObject` - can represent an instance of any class type
 */

struct MyStruct { }
class MySuperClass { }
class MySubClass: MySuperClass { }

let anys: [Any] = [1, "foo", true, { $0 * 2 }, MyStruct() ]

//let anyObjects: [AnyObject] = [MyStruct(), 1, { $0 * 2 }]
let anyObjects: [AnyObject] = [MySuperClass(), MySubClass()]


//: [Next](@next)
