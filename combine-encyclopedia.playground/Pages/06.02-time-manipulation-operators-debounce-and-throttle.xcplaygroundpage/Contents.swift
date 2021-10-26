//: [Previous](@previous)

import Foundation
import Combine
import SwiftUI
import PlaygroundSupport

let subject = PassthroughSubject<String, Never>()
let debounceDelay = 1.0
let throttleDelay = 1.0

let debounced = subject
  .debounce(for: .seconds(debounceDelay),
            scheduler: DispatchQueue.main)
  .share()

let throttled = subject
  .throttle(for: .seconds(throttleDelay),
               scheduler: DispatchQueue.main, latest: false)
  .share()

let subjectTimeline = TimelineView(title: "Emitted values")
let debouncedTimeline = TimelineView(title: "Debounced values")
let throttledTimeline = TimelineView(title: "Throttled values")

let view = VStack(spacing: 100) {
  subjectTimeline
  debouncedTimeline
  throttledTimeline
}

PlaygroundPage.current.liveView =
  UIHostingController(rootView: view.frame(width: 375, height: 600))

subject.displayEvents(in: subjectTimeline)
debounced.displayEvents(in: debouncedTimeline)
throttled.displayEvents(in: throttledTimeline)

subject.feed(with: typingHelloWorld)

let subjectSubscription = subject
  .sink { string in
    print("+\(deltaTime)s: Subject emitted: \(string)")
  }

let debouncedSubscription = debounced
  .sink { string in
    print("+\(deltaTime)s: Debounced emitted: \(string)")
  }

let throttledSubscription = throttled
  .sink { string in
    print("+\(deltaTime)s: Throttled emitted: \(string)")
  }


//: [Next](@next)
