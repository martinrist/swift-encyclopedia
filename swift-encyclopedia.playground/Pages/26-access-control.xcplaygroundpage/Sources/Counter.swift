// `open` access allows an entity to be used outside its declaring
// module.  Typically used to specify the public interface to a module.
// `open` also allows a class to be subclassed from outside the module.
open class OpenCounter {
  public var count = 0

  // By default, this function is `internal`, so not accessible outside
  // the module.  We declare it `public` to avoid this
  public func increment(by inc: Int = 1) {
    count += inc
  }

  open func openIncrement(by inc: Int = 1) {
    count += inc
  }

  // By default, this inialiser is `internal`, so not accessible outside
  // the module.  We declare it `public` to avoid this
  public init() {  }
}

// `public` access allows an entity to be used outside its declaring
// module.  Typically used to specify the public interface to a module.
// `public` prevents a class being subclassed from outside the module.
//
// `public` types default to having `internal` members, so these need
// to be explicitly given higher access to be accessibile outside the
// module.
public class PublicCounter {
  var count = 0
  public func increment(by inc: Int = 1) {
    count += inc
  }
  public init() {  }
}

// `internal` access allows entities to be used within a soruce file in
// the defining module, but not in any source file from outside the module
internal class InternalCounter {
  var count = 0

  func increment(by inc: Int = 1) {
    count += inc
  }
}


// `fileprivate` access restricts the use of an entity to its own defining
// source file.  We camn use this to hide implementation details of a
// specific piece of functionality when details are just used in that file.

fileprivate class FilePrivateCounter {
  var count = 0

  func increment(by inc: Int = 1) {
    count += inc
  }
}


// `private` access restricts the use of an identity to the enclosing
// declaration and to extension of that declaration in the same file

class CounterWithPrivateCount {
  private var count = 0
  public func increment(by inc: Int = 1) {
    count += inc
  }
}

extension CounterWithPrivateCount {
  public func decrementWithinModule(by dec: Int = 1) {
    // This extension can access `count` as it's in the same file
    count -= dec
  }
}

class FilePrivateAccessExample {
  func canAccessFilePrivateEntityInSameFile() {
    let filePrivateCounter = FilePrivateCounter()
    filePrivateCounter.increment()
  }
}
