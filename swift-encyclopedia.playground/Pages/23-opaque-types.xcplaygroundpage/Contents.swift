//: [Previous](@previous)

//: ## [23 - Opaque Types](https://docs.swift.org/swift-book/LanguageGuide/OpaqueTypes.html)

//: ### The Problem That Opaque Types Solve

//: Consider writing a set of structs to model ASCII art shapes

protocol Shape {
  func draw() -> String
}

struct Triangle: Shape {
  var size: Int
  func draw() -> String {
    var result = [String]()
    for length in 1...size {
      result.append(String(repeating: "*", count: length))
    }
    return result.joined(separator: "\n")
  }
}
let smallTriangle = Triangle(size: 3)
print("Small Triangle:\n\(smallTriangle.draw())\n")

//: We could use generics to implement flipping shapes vertically, but the flipped result exposes the exact generic types used to create it:

struct FlippedShape<T: Shape>: Shape {
  var shape: T
  func draw() -> String {
    shape.draw().split(separator: "\n")
      .reversed().joined(separator: "\n")
  }
}
let flippedTriangle = FlippedShape(shape: smallTriangle)
print("Flipped Triangle:\n\(flippedTriangle.draw())\n")
flippedTriangle

//: This gets worse if we now try to model joining two shapes - `joinedTriangles` has type `JoinedShape<Triangle, FlippedShape<Triangle>>`:

struct JoinedShape<T: Shape, U: Shape>: Shape {
  var top: T
  var bottom: U
  func draw() -> String {
    top.draw() + "\n" + bottom.draw()
  }
}
let joinedTriangles = JoinedShape(top: smallTriangle, bottom: flippedTriangle)
print("Joined Triangles:\n\(joinedTriangles.draw())\n")


//: ### Returning An Opaque Type

/*:
 An _opaque type_ is like the reverse of a _generic type_:

 - Generic types let the code that calls the funciton pick the types for the functions parameters and return value in a way that the funciton implementation doesn't know about.

 - Opaque types let the function implementation pick the type for the value it returns in a way that the calling code doesn't know about.
 */

struct Square: Shape {
  var size: Int
  func draw() -> String {
    let line = String(repeating: "*", count: size)
    let result = Array<String>(repeating: line, count: size)
    return result.joined(separator: "\n")
  }
}

// `some Shape` means the function returns a value of some given type that conforms to `Shape` without specifying any particular concrete type.
func makeTrapezoid() -> some Shape {
  let top = Triangle(size: 2)
  let middle = Square(size: 2)
  let bottom = FlippedShape(shape: top)
  return JoinedShape(
    top: top,
    bottom: JoinedShape(top: middle, bottom: bottom))
}

let trapezoid = makeTrapezoid()
print("Trapezoid:\n\(trapezoid.draw())\n")


func flip<T: Shape>(_ shape: T) -> some Shape {
  FlippedShape(shape: shape)
}

func join<T: Shape, U: Shape>(_ top: T, _ bottom: U) -> some Shape {
  JoinedShape(top: top, bottom: bottom)
}

let opaqueJoinedTriangles = join(smallTriangle, flip(smallTriangle))
print("Opaque Joined Triangles:\n\(opaqueJoinedTriangles.draw())\n")


//: Functions that return opaque types must return the same concrete type from each code path:

//func invalidFlip<T: Shape>(_ shape: T) -> some Shape {
//    if shape is Square {
//        return shape // Error: return types don't match
//    }
//    return FlippedShape(shape: shape) // Error: return types don't match
//}


//: ### Differences Between Opaque Types and Protocol Types

/*:
 Returning an opaque type looks similar to returning a protocol type from the function, but they differ in terms of whether they preserve type identity:

 - Opaque return types refer to one specific type, although the caller of the function isn't able to see which type.
 - Protocol return types can refer to any type that conforms to the protocol.
 */

//: e.g. here's a version of `flip(_:)` that uses a protocol type as its return type.
func protoFlip<T: Shape>(_ shape: T) -> Shape {
  FlippedShape(shape: shape)
}

//: `protoFlip(_:)` has a looser API contract with its caller than `flip(_:)` - for example it isn't required to always return a value of the same type, e.g.:

func protoFlip2<T: Shape>(_ shape: T) -> Shape {
  if shape is Square {
    return shape                // error if returning `some Shape`
  }
  return FlippedShape(shape: shape)
}

//: Because `protoFlip(_:)` has less-specific return-type information than `filp(_:)`, many operations that depend on type information won't work (e.g. `==`, even if we give `Shape` an implementation):

extension Shape {
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.draw() == rhs.draw()
  }
}

//: This all works as expected...

let opaqueFlippedTriangle = flip(smallTriangle)
let sameOpaqueThing = flip(smallTriangle)
opaqueFlippedTriangle == sameOpaqueThing


//: ... but this doesn't:
let protoFlippedTriangle = protoFlip(smallTriangle)
let sameProtoThing = protoFlip(smallTriangle)
// Error: Binary operator `==` cannot be applied to two 'Shape' operands
//protoFlippedTriangle == sameProtoThing

//: The problem with the protocol return types is that the implementation of `==` on `Shape` takes parameters of type `Self`, which matches whatever concrete type adopts the protocol, but adding the `Self` requirement to the protocol prevents the type erasure that happens when the protocol is used as a type.

//: Opaque return types preserve the identity of the underlying type, which means Swift can infer associated types, which lets you use an opaque return type in places where protocol types can't be used.
protocol Container {
  associatedtype Item
  var count: Int { get }
  subscript(i: Int) -> Item { get }
}
extension Array: Container { }

//: `Container` can't be used as a return type, because it has an associated type:
//func makeProtocolContainer<T>(item: T) -> Container {
//  return [item]
//}

//: It also can't be used as a constraint in a generic return type because there isn't enough information outside the function body to infer what the generic type needs to be:
//func makeProtocolContainer<T, C: Container>(item: T) -> C {
//  return [item]
//}

//: Returning the opaque type `some Container` expresses the desired API contract - that the function returns a `Container`, but declines to specify the container's type:
func makeOpaqueContainer<T>(item: T) -> some Container {
  return [item]
}

let opaqueContainer = makeOpaqueContainer(item: 12)
let twelve = opaqueContainer[0]
type(of: twelve)

//: [Next](@next)
