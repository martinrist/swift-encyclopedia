class CounterAccessExample {

  // `open` entities can be accessed from within the same module
  func accessOpenCounterFromSameModule() {
    let openCounter = OpenCounter()
    openCounter.increment()
  }

  // `internal` entities can be accessed from within the same module
  func accessInternalCounterFromSameModule() {
    let internalCounter = InternalCounter()
    internalCounter.increment()
  }

  // `fileprivate` entities can't be accessed from outside the declaring
  // file, even from the same module
  func cantAccessFilePrivateEntityFromDifferentFileInSameModule() {

    // Nope!
    //let filePrivateCounter = FilePrivateCounter()
  }

}

extension CounterWithPrivateCount {
  public func decrement(by dec: Int = 1) {
    // This extension can't access `count` because it's declared `private`
    // and is in another file
    // count -= dec
  }
}


// We can subclass an `open` class from within the module
class OpenCounterSubclass: OpenCounter {
  // We can override `increment` here, because we're in the same module
  override public func increment(by inc: Int = 10) {
    count += inc
  }
}

// We can also subclass a `public` class from inside the module (unlike from outside)
class PublicCounterSubclass: PublicCounter { }
