import Foundation
import ReactiveSwift
import TimelaneCore

@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
public extension SignalProducer {
    /// The `lane` operator logs the subscription and its events to the Timelane Instrument.
    ///
    ///  - Note: You can download the Timelane Instrument from http://timelane.tools
    /// - Parameters:
    ///   - name: A name for the lane when visualized in Instruments
    ///   - filter: Which events to log subscriptions or data events.
    ///             For example for a subscription on a subject you might be interested only in data events.
    ///   - transformValue: An optional closure to format the subscription values for displaying in Instruments.
    ///                     You can not only prettify the values but also change them completely, e.g. for arrays you can
    ///                     it might be more useful to report the count of elements if there are a lot of them.
    ///   - value: The value emitted by the subscription
    func lane(_ name: String,
              filter: Timelane.LaneTypeOptions = .all,
              file: StaticString = #file,
              function: StaticString = #function,
              line: UInt = #line,
              transformValue transform: @escaping (_ value: Value) -> String = { String(describing: $0) },
              logger: @escaping Timelane.Logger = Timelane.defaultLogger) -> SignalProducer<Value, Error> {
        lift { $0.lane(name, filter: filter, transformValue: transform, logger: logger) }
    }
}
