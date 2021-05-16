//: [Previous](@previous)
//: ## 30 - Encoding & Decoding Types

/*:
 See also:
 - [Swift Apprentice - Chapter 22 - 'Encoding & Decoding Types'](https://www.raywenderlich.com/books/swift-apprentice/v6.0/chapters/22-encoding-decoding-types)
 */

//: ### `Encodable` and `Decodable` Protocols

/*:
 Serialisation and deserialisation in Swift is handled via the `Encodable` and `Decodable` protocols:

 - `Encodable` expresses that a type can convert itself to another representation, via the `encode(to: Encoder)` method:

    ![Encoding a Type](encoding.png)

 - `Decodable` expresses that a type can be constructed from another representation, via the `init(from: Decoder)` initaliser:

    ![Decoding a Type](decoding.png)

 The compiler can automatically gnerate conformance to both `Encodable` and `Decodable` if all the stored properties also conform.

 `Codable` combines both encoding and decoding - `typealias Codable = Encodable & Decodable`
 */

struct Employee: Codable {
  var name: String
  var id: Int
  var favouriteToy: Toy?
}

struct Toy: Codable {
  var name: String
}


//: ### Encoding & Decoding Custom Types

//: Swift provides various versions of encoders and decoders, for various data formats, e.g. `JSONEncoder` / `JSONDecoder`:

let martin = Employee(name: "Martin", id: 42, favouriteToy: Toy(name: "Joey"))

import Foundation
let jsonEncoder = JSONEncoder()
let jsonData = try jsonEncoder.encode(martin)

String(data: jsonData, encoding: .utf8)

let jsonDecoder = JSONDecoder()
try jsonDecoder.decode(Employee.self, from: jsonData)


//: ### Renaming Properties with `CodingKeys`

//: By default, coding and encoding uses the property names as the values in the encoding.  This can be overridden by adding a nested enumeration `CodingKeys`:
struct EmployeeWithCustomEmployeeId: Codable {
  var name: String
  var id: Int
  var favouriteToy: Toy?

  enum CodingKeys: String, CodingKey {
    case id = "employeeId"
    case name
    case favouriteToy
  }
}

let david = EmployeeWithCustomEmployeeId(name: "David", id: 85, favouriteToy: Toy(name: "Sammy"))
String(data: try jsonEncoder.encode(david), encoding: .utf8)


//: ### Manual Encoding & Decoding

//: To manually encode a type, we need to provide custom versions of `encode(to:)`:

struct EmployeeWithCustomCoding: Encodable {
  var name: String
  var id: Int
  var favouriteToy: Toy?

  enum CodingKeys: String, CodingKey {
    case id = "employeeId"
    case name
    case gift
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    // `container` now allows us to manually manage the encoding
    try container.encode(name, forKey: .name)
    try container.encode(id, forKey: .id)
    try container.encode(favouriteToy?.name, forKey: .gift)
  }
}

let sally = EmployeeWithCustomCoding(name: "Sally", id: 27, favouriteToy: Toy(name: "Wilbur"))
String(data: try jsonEncoder.encode(sally), encoding: .utf8)

//: Then, to decode the type, we need to provide `init(from:)`:

extension EmployeeWithCustomCoding: Decodable {
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    name = try values.decode(String.self, forKey: .name)
    id = try values.decode(Int.self, forKey: .id)
    if let gift = try values.decode(String?.self, forKey: .gift) {
      favouriteToy = Toy(name: gift)
    }
  }
}

//: To miss out `nil` values, rather than encoding them as `null`, use `encodeIfPresent` and `decodeIfPresent`:

let billy = EmployeeWithCustomCoding(name: "Billy", id: 102, favouriteToy: nil)
String(data: try jsonEncoder.encode(billy), encoding: .utf8)

struct EmployeeWithCustomCodingWithoutMissingToy: Codable {
  var name: String
  var id: Int
  var favouriteToy: Toy?

  enum CodingKeys: String, CodingKey {
    case id = "employeeId"
    case name
    case gift
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(id, forKey: .id)
    try container.encodeIfPresent(favouriteToy?.name, forKey: .gift)
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    name = try values.decode(String.self, forKey: .name)
    id = try values.decode(Int.self, forKey: .id)
    if let gift = try values.decodeIfPresent(String.self, forKey: .gift) {
      favouriteToy = Toy(name: gift)
    }
  }
}


//: ### Testing `Encoder`s and `Decoder`s:

import XCTest

class EncoderDecoderTests: XCTestCase {
  var jsonEncoder: JSONEncoder!
  var jsonDecoder: JSONDecoder!
  var toy1: Toy!
  var employee1: Employee!

  override func setUp() {
    super.setUp()
    jsonEncoder = JSONEncoder()
    jsonDecoder = JSONDecoder()
    toy1 = Toy(name: "Teddy Bear")
    employee1 = Employee(name: "John", id: 7, favouriteToy: toy1)
  }

  func testEncoder() {
    let jsonData = try? jsonEncoder.encode(employee1)
    XCTAssertNotNil(jsonData, "Encoding failed")
    let jsonString = String(data: jsonData!, encoding: .utf8)!
    XCTAssertEqual(jsonString, "{\"name\":\"John Appleseed\",\"gift\":\"Teddy Bear\",\"employeeId\":7}")
  }

  func testDecoder() {
    let jsonData = try! jsonEncoder.encode(employee1)
    let employee2 = try? jsonDecoder.decode(Employee.self, from: jsonData)
    XCTAssertNotNil(employee2)

    XCTAssertEqual(employee1.name, employee2!.name)
    XCTAssertEqual(employee1.id, employee2!.id)
    XCTAssertEqual(employee1.favouriteToy?.name, employee2!.favouriteToy?.name)
  }
}

EncoderDecoderTests.defaultTestSuite.run()
//: [Next](@next)
