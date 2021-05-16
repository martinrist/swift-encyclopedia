//: [Previous](@previous)
//: ## [23 - Automatic Reference Counting](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 14 - 'Advanced Classes'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/14-advanced-classes)
 - [Swift Apprentice - Chapter 23 - 'Memory Management'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/23-memory-management)
 */

//: ### How ARC Works

//: Creating an instance of a class, causes ARC to allocate memory to store information about that instance and its stored properties.  When an instance is no longer needed, ARC frees up that memory from use.

//: ARC tracks how many properties, constants and variables are currently referring to each class instance, and will not deallocate an instance while there is at least one active reference to it.

//: Assigning a class instance to a property, constant or variable creates a _strong reference_ to the instance.

//: ARC only applies to reference types, not to structs or enumerations.

//: Consider two classes, `Person` and `Apartment` that print out messages when initialised and deinitialised:

class Person {
  let name: String
  var apartment: Apartment?
  init(name: String) {
    self.name = name
    print("\(name) is being initialised")
  }
  deinit {
    print("\(name) is being deinitialised")
  }
}

class Apartment {
  let unit: String
  var tenant: Person?
  init(unit: String) {
    print("Apartment \(unit) is being initialised")
    self.unit = unit
  }
  deinit {
    print("Apartment \(unit) is being deinitialised")
  }
}

//: Declare three variables that can point to instances of `Person`.  Set these to point to the same instance.  There are now three strong references to a single `Person` instance:
var ref1: Person? = Person(name: "Martin")
var ref2: Person? = ref1
var ref3: Person? = ref1
print("There are now three strong references to a single `Person` instance")

//: Breaking the first two references doesn't cause the `Person` instance to be deallocated:
ref1 = nil
ref2 = nil
print("The `Person` instance hasn't been deallocated yet")

//: It's only deallocated when the last strong reference is removed
print("Removing the last strong reference `ref3`")
ref3 = nil
print("The `Person` instance has now been deallocated")
print()


//: ### Strong Reference Cycles

//: If two class instances hold a strong reference to each other they create a _strong reference cycle_ and never get deallocated.  This causes memory to leak:

var john: Person?
var unit4A: Apartment?

john = Person(name: "John")
unit4A = Apartment(unit: "4A")

/*:
 Linking `john` and `unit4A` creates a strong reference cycle between them:

 ![A Strong Reference Cycle](strongReferenceCycle01.png)
 */
john!.apartment = unit4A
unit4A!.tenant = john
print("`john` and `unit4A` are linked in a strong reference cycle")

/*:
 Setting both references to `nil` does not cause them to be deallocated because of the strong cycle

 ![A Strong Reference Cycle](strongReferenceCycle01.png)
 */

print("Setting `john` and `unit4A` to `nil`")
john = nil
unit4A = nil
print("`john` and `unit4A` have not been deallocated")
print()


//: ### Weak References

//: Weak references do not keep a strong hold on the instance they refer to, and so don't prevent ARC disposing of the referenced instance.  Use weak references to point to the object that has a `shorter` lifetime (e.g. the `Person` type in the case above):

class PersonAsWeakTenant {
  let name: String
  var apartment: WeaklyTenantedApartment?
  init(name: String) {
    self.name = name
    print("\(name) is being initialised")
  }
  deinit {
    print("\(name) is being deinitialised")
  }
}

class WeaklyTenantedApartment {
  let unit: String
  weak var tenant: PersonAsWeakTenant?
  init(unit: String) {
    self.unit = unit
    print("Apartment \(unit) is being initialised")
  }
  deinit {
    print("Apartment \(unit) is being deinitialized")
  }
}

var weakJohn: PersonAsWeakTenant? = PersonAsWeakTenant(name: "John (weak)")
var weakUnit4A: WeaklyTenantedApartment? = WeaklyTenantedApartment(unit: "4A-with-weak-tenant")

/*:
 Linking `weakJohn` and `weakUnit4A` creates a strong reference cycle between them:

 ![A Weak Reference Cycle](weakReference01.png)
 */
weakJohn!.apartment = weakUnit4A
weakUnit4A!.tenant = weakJohn
print("`weakJohn` and `weakUnit4A` are linked, but weakly")

/*:
 Setting `weakJohn` to `nil` deallocates it because it has no strong references pointing to it (just one weak one):

 ![A Weak Reference Cycle](weakReference02.png)
 */
print("Setting `weakJohn` to `nil`")
weakJohn = nil
print("`weakJohn` has been deallocated ")
weakUnit4A!.tenant        // now `nil`

/*:
 Setting `weakUnit4A` to `nil` now deallocates it because it has no strong references point to it (the strong reference from `weakJohn` has gone:

 ![A Weak Reference Cycle](weakReference03.png)
 */
weakUnit4A = nil
print("Both instances have been deallocated")
print("")


//: ### Unowned References

//: Unowned references are used when the other instance has the same or longer lifetime.  They are always expected to have a value, so they are defined using non-optional types.  Therefore you need to be sure that the other instance won't get deallooated, because if you try to access the value of an unowned reference and it has been deallocated, you'll get a runtime error.

class Customer {
  let name: String
  var card: CreditCard?
  init(name: String) {
    self.name = name
    print("\(name) is being initialised")
  }
  deinit {
    print("\(name) is being deinitialised")
  }
}

class CreditCard {
  let number: UInt64

  // A credit card never outlives a customer, so it can be unowned
  unowned let customer: Customer

  init(number: UInt64, customer: Customer) {
    self.number = number
    self.customer = customer
  }
  deinit {
    print("Card #\(number) is being deinitialised")
  }
}

/*:
 Create a `Customer` instance with a linked `CreditCard` instance.  `CreditCard` now has an `unowned` reference to `johnWithCard`:

 ![An `unowned` Reference](unownedReference01.png)
 */

var johnWithCard: Customer? = Customer(name: "John with Credit Card")
johnWithCard!.card = CreditCard(number: 1234_5678_8912_3456, customer: johnWithCard!)

/*:
 Setting `johnWithCard` to `nil` breaks the single strong reference to it, so it's deallocated:

 ![An `unowned` Reference](unownedReference02.png)

 Then, the `CreditCard` instance also has no strong references pointing to it, so it's also deallocated.
 */

print("Setting `johnWithCard` to `nil`")
johnWithCard = nil
print()


//: ### Strong Reference Cycles for Closures

//: Strong reference cycles can also be created by assigning a closure to a property of a class instance, and the body of that closure captures the instance (e.g. accesses an instance of `self`, one of its properties, or calls a method on `self`).  These cause the closure to 'capture' `self`.

//: This is because closures are reference types, so when you assign them to a property, you get a class instance and a closure that keep each other alive.

class HTMLElement {
  let name: String
  let text: String?

  // This lazy property references a closure.  It's like an instance method that can be replaced at runtime
  lazy var asHTML: () -> String = {
    if let text = self.text {
      return "<\(self.name)>\(text)</\(self.name)>"
    } else {
      return "<\(self.name) />"
    }
  }

  init(name: String, text: String? = nil) {
    self.name = name
    self.text = text
  }

  deinit {
    print("\(name) is being deinitialised")
  }
}

//: Here's how we can use `HTMLElement` for a 'paragraph' (`<p>`) element:
var paragraph: HTMLElement? = HTMLElement(name: "p", text: "Hello, world")
paragraph!.asHTML()

/*:
 At the moment, this has a strong reference cycle `self` -> `asHTML` -> closure -> captured `self`, so setting `paragraph` to `nil` won't deallocate it:

 ![Closure Reference Cycle](closureReferenceCycle01.png)
 */
print("Setting `paragraph` to `nil`")
paragraph = nil
print("`paragraph` has not been deallocated")
print()

//: We can resolve this strong reference cycle using a _capture list_ as part of the closure's definition.  This defines the rules to use when capturing one or more reference types within the closure body:

class SomeStruct {
  var delegate: AnyObject?

  lazy var someClosure = {
    [unowned self, weak delegate = self.delegate]
    (index: Int, stringToProcess: String) -> () in
    // closure body goes here
  }

  lazy var anotherClosure = {
    [unowned self, weak delegate = self.delegate] in
    // closure body goes here
  }
}

//: Define a capture in a closure as an `unowned` reference when the closure and the instance it captures will always refer to each other, and will always be deallocated at the same time.

//: Conversely, declare the capture as `weak` when the captured reference may become `nil` at some point in the future.

class HTMLElementFixed {
  let name: String
  let text: String?

  lazy var asHTML: () -> String = {
    [unowned self] in
    if let text = self.text {
      return "<\(self.name)>\(text)</\(self.name)>"
    } else {
      return "<\(self.name) />"
    }
  }

  init(name: String, text: String? = nil) {
    self.name = name
    self.text = text
  }

  deinit {
    print("\(name) is being deinitialised")
  }
}

/*:
 Using `HTMLElementFixed` - see how the reference from the closure back to the `HTMLElementFixed` instance is now `unowned`:

 ![Closure Reference Cycle](closureReferenceCycle02.png)
 */
var paragraphFixed: HTMLElementFixed? = HTMLElementFixed(name: "p", text: "hello, world")
paragraphFixed!.asHTML()

//: Setting `paragraphFixed` to `nil` now deinitialises it as expected:
paragraphFixed = nil

//: [Next](@next)
