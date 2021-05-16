//: [Previous](@previous)
//: ## [15 - Deinitialisation](https://docs.swift.org/swift-book/LanguageGuide/Deinitialization.html)

/*:
 See also:
 - [Swift Apprentice - Chapter 14 - 'Advanced Classes'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/14-advanced-classes)
 */

//: ### How Deinitialisation Works

//: Swift deallocates instance when they are no longer used (via ARC).  Class definitions (but not structs) can have a deinitialiser, called when the instance is deinitialised.  This can be used to do custom cleanup, e.g. closing external files:

class Bank {
  static var coinsInBank = 10_000

  static func distribute(coins numberOfCoinsRequested: Int) -> Int {
    let numberOfCoinsToVend = min(numberOfCoinsRequested, coinsInBank)
    coinsInBank -= numberOfCoinsToVend
    return numberOfCoinsToVend
  }

  static func receive(coins: Int) {
    coinsInBank += coins
  }
}


class Player: CustomPlaygroundDisplayConvertible {

  var coinsInPurse: Int

  var playgroundDescription: Any {
    return "Player - \(coinsInPurse) coins"
  }

  init(coins: Int) {
    coinsInPurse = Bank.distribute(coins: coins)
  }

  func win(coins: Int) {
    coinsInPurse += Bank.distribute(coins: coins)
  }

  deinit {
    print("Deinitialising player - returning \(coinsInPurse) to Bank")
    Bank.receive(coins: coinsInPurse)
  }
}


// Ready player 1
var playerOne: Player? = Player(coins: 100)
print("New player joined with \(playerOne!.coinsInPurse) coins")
print("Now \(Bank.coinsInBank) coins left in bank")
playerOne!.win(coins: 2_000)
print("PlayerOne won 2000 coins and now has \(playerOne!.coinsInPurse)")
print("Now \(Bank.coinsInBank) coins left in bank")
playerOne = nil
print("Now \(Bank.coinsInBank) coins left in bank")


//: Superclass deinitialisers are inherited by their subclasses, and the superclass deinitialiser is called automatically at the end of a subclass deinitialiser implementation.

//: [Next](@next)
