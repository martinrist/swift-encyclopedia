//: [Previous](@previous)
//: ## [24 - Memory Safety](https://docs.swift.org/swift-book/LanguageGuide/MemorySafety.html)


//: ### Memory Conflicts

/*:
 A conflict can occur if you have two accesses that meet the following conditions:

 - At least one access is a _write_ access or a _nonatomic_ access
 - They both access the same location in memory
 - Their durations overlap

 An access is _atomic_ if it only involces C atomic actions (as per the `stdatomic(3)` man page), otherwise they are _nonatomic_.

 Accesses are _instantaneous_ if it's not possible for code to run after the access starts but before it ends.  All the accesses below are instantaneous:
 */

func oneMore(than number: Int) -> Int {
  return number + 1
}

var myNumber = 1
myNumber = oneMore(than: myNumber)
myNumber

/*:
 However, there are several ways to access memory, called _long-term accesses_ that span the execution of other code.  This could allow accesses to _overlap_, e.g.:

 - in-out parameters in functions
 - mutating methods of a structure
 */


//: ### Conflicting Access to In-Out Parameters

/*:
 Functions have 'long-term' write access to all of their `inout` parameters.  Write access for an `inout` parameter starts after all of the non-`inout` parameters have been evaluated and lasts for the entire duration of the function call.

 So, for exmaple, you can't read the original value of an `inout` parameter even if other rules would allow it:

 ![Memory Increment](memoryIncrement.png)

 */

var stepSize = 1

func increment(_ number: inout Int) {
  number += stepSize
}

// increment(&stepSize)  // This crashes if uncommented

//: To solve this, make an explicit copy of `stepSize` before calling `increment`:
var copyOfStepSize = stepSize
increment(&copyOfStepSize)
stepSize = copyOfStepSize

//: Another consequence is that you can't pass a single variable as the argument for multiple `inout` parameters:

func balance(_ x: inout Int, _ y: inout Int) {
  let sum = x + y
  x = sum / 2
  y = sum - x
}

var playerOneScore = 42
var playerTwoScore = 30

//: This is OK because the two arguments are different
balance(&playerOneScore, &playerTwoScore)

//: This isn't because they point to the same memory location
//balance(&playerOneScore, &playerOneScore)


//: ### Conflicting Access to `self` in Methods

//: A `mutating` method on structures has write access to `self` for the duration of the method call.

struct Player {
  var name: String
  var health: Int
  var energy: Int

  static let maxHealth = 10
  mutating func restoreHealth() {
    // write access to `self` starts here
    health = Player.maxHealth
    // write access to `self` ends here
  }
}

extension Player {
  mutating func shareHealth(with teammate: inout Player) {
    balance(&teammate.health, &health)
  }
}

var oscar = Player(name: "Oscar", health: 10, energy: 10)
var maria = Player(name: "Maria", health: 5, energy: 10)

/*:
 Here, there's a write access to `oscar` during the method call (because `shareHealth` is a mutating method), and a write access to `maria` for the same duration (because it's an in-out parameter) but they're accesses to different memory locations, so they don't conflict:

 ![Share Health - Maria](memoryShareHealthMaria.png)
 */
oscar.shareHealth(with: &maria)

/*:
 The following doesn't work because both accesses are to `oscar`, so they conflict:

 ![Share Health - Oscar](memoryShareHealthOscar.png)
 */
// oscar.shareHealth(with: &oscar)


//: ### Conflicting Access to Properties

//: For value types (structures, tuples, enumerations), mutating any piece of the value mutates the whole, so read / write access to one of the properties requires read / write access to the whole.

//: e.g. overlapping write accesses to the elements of a tuple produces a conflict:
var playerInformation = (health: 10, energy: 20)
// balance(&playerInformation.health, &playerInformation.energy)

//: The same happens for overlapping write accesses to properties of a structure stored as a global variable:
var holly = Player(name: "Holly", health: 10, energy: 10)
//balance(&holly.health, &holly.energy)

//: If the variable is local to the function, the compiler can prove that overlapping accesses are safe:
func someFunction() {
  var oscar = Player(name: "Oscar", health: 10, energy: 10)
  balance(&oscar.health, &oscar.energy)
}
someFunction()

//: [Next](@next)
