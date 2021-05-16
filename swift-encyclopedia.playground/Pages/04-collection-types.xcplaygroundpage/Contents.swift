//: [Previous](@previous)
//: ## [4 - Collection Types](https://docs.swift.org/swift-book/LanguageGuide/CollectionTypes.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 7 - 'Arrays, Dictionaries & Sets'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/7-arrays-dictionaries-sets)
 - [Swift Apprentice - Chapter 8 - 'Collection Iteration with Closures'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/8-collection-iteration-with-closures)
 */


//: ### Arrays

//: An `Array` is an ordered collection of values of the same type.  There are various ways of creating an `Array`:
var someInts = [1, 2, 3, 4]
var someMoreInts: Array<Int> = [5, 6, 7, 8]
var evenMoreInts = Array<Int>(arrayLiteral: 9, 10, 11, 12)
var threeDoubles = Array(repeating: 0.0, count: 3)
var anotherThreeDoubles = Array(repeating: 2.5, count: 3)
var sixDoubles = threeDoubles + anotherThreeDoubles

//: `count` and `isEmpty` help determine the size of an `Array`:
threeDoubles.count
threeDoubles.isEmpty
[].isEmpty

//: Items can be appended to a mutable array using `append(_:)` or `+=`:
var shoppingList = ["Eggs"]
shoppingList.append("Bacon")
shoppingList.append(contentsOf: ["Ham", "Beans"])
shoppingList += ["Tomato", "Potato"]

//: Values can be retrieved from an `Array`, or edited using subscript syntax:
shoppingList[0]
shoppingList[0] = "Bananas"
shoppingList

//: To insert at / remove from a specific index, use `insert(_:at:)` / `remove(at:)`:
shoppingList.insert("Maple Syrup", at: 2)
shoppingList.remove(at: 2)        // Returns "Maple Syrup"
shoppingList                      // No longer contains "Maple Syrup"

//: Iterate over an array using `for-in` to get items, or `enumerated()` to get index/value pairs:
for item in shoppingList {
  print(item)
}

for (index, value) in shoppingList.enumerated() {
  print("\(index) : \(value)")
}


//: ### Sets

//: A `Set` is an unordered collection of unique values.  Types must be _hashable_ to be stored in a set - they must conform to `Hashable`, but a lot of this can be synthesised automatically:
struct Thing : Hashable, Equatable {
  let field1: Int
  let field2: Double
}

//: Creating sets:
var letters = Set<Character>()
let favouriteGenres: Set = ["Classical", "Ambient", "Dark Techno", "Mathrock"]
let setofThings : Set = [ Thing(field1: 1, field2: 1.0),
                          Thing(field1: 2, field2: 2.0)]

//: `count` and `isEmpty` properties work as for Arrays:
letters.isEmpty
favouriteGenres.count

//: Insertion works as for arrays, but duplicates are ignored.  Note the return type tells us whether insertion actually occurred:
letters.insert("a")
letters.insert("b")
letters.insert("b")
letters

//: Use `contains(_:)` to determine whether the value is in the set:
letters.contains("b")
letters.contains("z")

//: Sets don't have a built-in order, so to iterate in order, use `sorted()`:
for genre in favouriteGenres.sorted() {
  print(genre)
}
print()

//: Use `sorted(by:)` to provide a different comparator.  Note the use of `>` as a function literal:
for genre in favouriteGenres.sorted(by: >) {
  print("\(genre)")
}

//: ### Set Operations

//: Sets provide efficient operations for intersection, union etc.
let oddDigits: Set = [1, 3, 5, 7, 9]
let evenDigits: Set = [0, 2, 4, 6, 8]
let singleDigitPrimes: Set = [2, 3, 5, 7]

oddDigits.union(evenDigits).sorted()
oddDigits.intersection(evenDigits).sorted()
oddDigits.subtracting(singleDigitPrimes).sorted()
oddDigits.symmetricDifference(singleDigitPrimes).sorted()

//: Also, `==`, `isSubset(of:)` / `isStrictSubset(of:)` and `isSuperset(of:)` / `isStrictSuperset(of:)` can be used to test set equality and membership:

let houseAnimals: Set = ["🐶", "🐱"]
let farmAnimals: Set = ["🐮", "🐔", "🐑", "🐶", "🐱"]
let cityAnimals: Set = ["🐦", "🐭"]

houseAnimals.isSubset(of: farmAnimals)
farmAnimals.isSuperset(of: houseAnimals)
farmAnimals.isDisjoint(with: cityAnimals)


//: ### Dictionaries

//: A `Dictionary` is an unordered collection of key-value associations, whose type is represented as `Dictionary<Key, Value>` or `[Key: Value]`:
var namesOfIntegers = [Int: String]()
namesOfIntegers = [1: "One", 2: "Two"]    // Dictionary literal

//: `count` and `isEmpty` properties work as for Arrays and Sets:
namesOfIntegers.count
[:].isEmpty

//: Dictionary entries can be accessed and modified using subscript notation. or equivalent methods:
namesOfIntegers[1]
namesOfIntegers[3] = "Three"
namesOfIntegers.updateValue("Fore", forKey: 4)
namesOfIntegers.updateValue("Four", forKey: 4)    // Returns old value
namesOfIntegers
namesOfIntegers[100]                              // Returns `nil` if not present

//: Entries can be deleted by assigning `nil` or using `removeValue(forKey:)`:
namesOfIntegers[4] = nil
namesOfIntegers.removeValue(forKey: 3)
namesOfIntegers

//: Iteration can be done with a `for-in` loop, `.forEach()` or using the `keys` and `values` properties:
for (integer, name) in namesOfIntegers {
  print("\(integer) - \(name)")
}

namesOfIntegers.forEach { integer, name in
  print("\(integer) - \(name)")
}

namesOfIntegers.keys
namesOfIntegers.values


//: [Next](@next)
