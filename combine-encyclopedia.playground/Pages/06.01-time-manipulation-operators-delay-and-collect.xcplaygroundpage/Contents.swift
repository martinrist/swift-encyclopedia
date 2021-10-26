//: [Previous](@previous)

import Foundation
import Combine
import SwiftUI
import PlaygroundSupport

let valuesPerSecond = 1.0
let delayInSeconds = 1.5
let collectTimeStride = 4

let sourcePublisher = PassthroughSubject<Date, Never>()
let delayedPublisher = sourcePublisher
  .delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)
let collectedPublisher = sourcePublisher
  .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
  .flatMap { dates in dates.publisher }

let subscription =
Timer.publish(every: 1.0 / valuesPerSecond,
              on: .main,
              in: .common)
  .autoconnect()
  .subscribe(sourcePublisher)

let sourceTimeline = TimelineView(
  title: "Emitted values (\(valuesPerSecond) per sec.):")
let delayedTimeline = TimelineView(
  title: "Delayed values (with a \(delayInSeconds)s delay):")
let collectedTimeline = TimelineView(
  title: "Collected values (every \(collectTimeStride)s):")

let view = VStack(spacing: 50) {
  sourceTimeline
  delayedTimeline
  collectedTimeline
}

PlaygroundPage.current.liveView =
UIHostingController(rootView: view.frame(width: 375, height: 600))

sourcePublisher.displayEvents(in: sourceTimeline)
delayedPublisher.displayEvents(in: delayedTimeline)
collectedPublisher.displayEvents(in: collectedTimeline)






//: [Next](@next)
