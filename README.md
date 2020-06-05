# ReactiveTimelane
[![CI Status](https://github.com/nkristek/ReactiveTimelane/workflows/CI/badge.svg)](https://github.com/nkristek/ReactiveTimelane/actions)

**ReactiveTimelane** provides operators for `Signal`, `SignalProducer` and `Lifetime` in [ReactiveSwift](https://github.com/ReactiveCocoa/ReactiveSwift) for profiling streams and lifetimes with the Timelane Instrument.

#### Contents:

- [Usage](#usage)
- [API Reference](#api-reference)
- [Installation](#installation)
- [Contribution](#contribution)

## Usage

> Before making use of ReactiveTimelane, you need to install the Timelane Instrument from http://timelane.tools

Import the `ReactiveTimelane` framework in your code:

```swift
import ReactiveTimelane
```

Use the `lane(_:)` operator to profile a subscription via the TimelaneInstrument. Insert `lane(_:)` at the precise spot in your code you'd like to profile like so:

```swift
let producer: SignalProducer<Void, Never> = SignalProducer(value: ())
producer
    .lane("Void producer")
    .start()
```

Then profile your project by clicking **Product > Profile** in Xcode's main menu.

For a more detailed walkthrough go to [http://timelane.tools](http://timelane.tools).

## API Reference

### `lane(_:filter:)`

Use `lane("Lane name")` to send data to both the subscriptions and events lanes in the Timelane Instrument.

`lane("Lane name", filter: .subscription)` sends begin/completion events to the Subscriptions lane. Use this syntax if you only want to observe the lifetime of the `Signal` / `SignalProducer`.

`lane("Lane name", filter: .event)` sends events and values to the Events lane. Use this filter if you are only interested in the values the `Signal` / `SignalProducer` emits.

Additionally you can transform the values logged in Timelane by using the optional `transformValue` trailing closure:

```swift
lane("Lane name", transformValue: { "Value is \($0)" })
```

## Installation

### Swift Package Manager

#### Automatically in Xcode:

- Click **File > Swift Packages > Add Package Dependency...**  
- Use the package URL `https://github.com/nkristek/ReactiveTimelane` to add ReactiveTimelane to your project.

#### Manually in your `Package.swift` file:

```swift
.package(url: "https://github.com/nkristek/ReactiveTimelane", from: "1.1.0")
```

## Contribution

If you find a bug feel free to open an issue. Contributions are also appreciated.
