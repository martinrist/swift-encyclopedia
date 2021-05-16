//: [Previous](@previous)
//: ## [19 - Nested Types](https://docs.swift.org/swift-book/LanguageGuide/NestedTypes.html)


//: ### Nested Types Example

//: Types can contain other types inside them, defined within the outer braces.  Types can be nested to any desired level:

struct BlackjackCard {

  // Nested `Suit` enumeration
  enum Suit: Character {
    case spades = "♠", hearts = "♡", diamonds = "♢", clubs = "♣"
  }

  // Nested `Rank` enumeration
  enum Rank: Int {
    case two = 2, three, four, five, six, seven, eight, nine, ten
    case jack, queen, king, ace

    // Doubly-nested `Values` struct
    struct Values {
      let first: Int, second: Int?
    }

    var values: Values {
      switch self {
      case .ace:
        return Values(first: 1, second: 11)
      case .jack, .queen, .king:
        return Values(first: 10, second: nil)
      default:
        return Values(first: self.rawValue, second: nil)
      }
    }
  }

  let rank: Rank, suit: Suit

  var description: String {
    var output = "suit is \(suit.rawValue),"
    output += " value is \(rank.values.first)"
    if let second = rank.values.second {
      output += " or \(second)"
    }
    return output
  }
}

let theAceOfSpades = BlackjackCard(rank: .ace, suit: .spades)
print("theAceOfSpaces: \(theAceOfSpades.description)")


//: Referring to Nested Types

//: To use a nested type outside its definition context, prefix the name with the containing type:
let heartsSymbol = BlackjackCard.Suit.hearts.rawValue


//: [Next](@next)
