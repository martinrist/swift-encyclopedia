//: [Previous](@previous)
//: ## [16 - Optional Chaining](https://docs.swift.org/swift-book/LanguageGuide/OptionalChaining.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 6 - 'Optionals'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/6-optionals)
 */

//: ### An Alternative to Forced Unwrapping

//: Whereas force-unwrapping crashes out, optional chaining fails gracefully when the optional is `nil`:

struct Person {
  var residence: Residence?
}

struct Residence {
  var rooms = [Room]()
  var numberOfRooms: Int {
    return rooms.count
  }
  var address: Address?

  func printNumberOfRooms() {
    print("The number of rooms is \(numberOfRooms)")
  }

  subscript(i: Int) -> Room {
    get {
      return rooms[i]
    }
    set {
      rooms[i] = newValue
    }
  }
}

struct Address {
  var number: String?
  var street: String?
  var city: String
}

struct Room {
  let name: String
}

var john = Person()

//: `john` has no residence so this returns `nil`, as opposed to a runtime error:
john.residence?.numberOfRooms
//john.residence!.numberOfRooms             // runtime error

//: Adding a `residence` to `john`, enables us to see that the result of `john.residence?.numbrOfRooms` is of type `Int?`:
john.residence = Residence()
john.residence?.rooms.append(Room(name: "Main room"))
john.residence?.numberOfRooms
type(of: john.residence?.numberOfRooms)



//: ### Setting Properties Through Optional Chaining

//: We can attempt to set a property through optional chaining, but it fails silently if attempting to set property on an instance which is `nil`:

var sally = Person()

func createAddress() -> Address {
  print("createAddress() called")
  return Address(number: "1", street: "Street", city: "City")
}
// Here, `createAddress()` isn't even called because `sally.residence` is `nil`:
sally.residence?.address = createAddress()
sally.residence


//: ### Calling Methods Through Optional Chaining

//: Just like acscessing properties, methods can be called through optional chaining:
sally.residence?.printNumberOfRooms()

//: `printNumberOfRooms()` actually has an implicit return type of `Void` - i.e.it returns `()`.  So, in the case of the above, the return type is `Void?`:
type(of: sally.residence?.printNumberOfRooms())

//: Because of this, it's possible to use `if let _` to check whether the call happened or not:
if let _ = sally.residence?.printNumberOfRooms() {
  print("It was possible to print the number of Sally's rooms")
} else {
  print("It was not possible to print the number of Sally's rooms")
}
print()


//: ### Accessing Subscripts through Optional Chaining

//: It's also possible to use optional chaining to retrieve and set values from a subscript:
let firstRoomsName = john.residence?[0].name      // :: String?

//: [Next](@next)
