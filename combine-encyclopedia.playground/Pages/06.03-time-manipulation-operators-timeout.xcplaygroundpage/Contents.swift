//: [Previous](@previous)

import Foundation
import Combine
import SwiftUI
import PlaygroundSupport

enum TimeoutError: Error {
  case timedOut
}

let subject = PassthroughSubject<Void, Never>()
let errorSubject = PassthroughSubject<Void, TimeoutError>()

let timedOutCompletionSubject = subject
  .timeout(.seconds(5), scheduler: DispatchQueue.main)

let timedOutErrorSubject = errorSubject
  .timeout(.seconds(5), scheduler: DispatchQueue.main) {
    .timedOut
  }


let timeline = TimelineView(title: "Button taps")
let timelineWithError = TimelineView(title: "Button taps")

let view = VStack(spacing: 100) {
  Button(action: {
    subject.send()
    errorSubject.send()
  }) {
    Text("Press me within 5 seconds")
  }
  timeline
  timelineWithError
}

PlaygroundPage.current.liveView =
UIHostingController(rootView: view.frame(width: 375, height: 600))

timedOutCompletionSubject.displayEvents(in: timeline)
timedOutErrorSubject.displayEvents(in: timelineWithError)

//: [Next](@next)
