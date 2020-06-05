import Foundation
import ReactiveSwift
import TimelaneCore

@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
public extension SignalProducer {
    /**
     This operator logs the lifetime of the subscription to the `SignalProducer` and its events to the Timelane Instrument.
     
     - Note: You can download the Timelane Instrument from [timelane.tools](http://timelane.tools).
     
     - Parameter name: A name for the lane when visualized in Instruments.
     
     - Parameter filter: Determines which metrics should be logged.
     
     - Parameter file: The name of the current file.
     
     - Parameter function: The name of the current function.
     
     - Parameter line: The number of the current line.
     
     - Parameter transformValue: An optional closure to format the subscription values for displaying in Instruments.
     
     - Parameter logger: A logger which should be used to log the specified metrics.
     
     - Returns: A `SignalProducer` where the specified metrics are logged for the Timelane Instrument.
     */
    func lane(_ name: String,
              filter: Timelane.LaneTypeOptions = .all,
              file: StaticString = #file,
              function: StaticString = #function,
              line: UInt = #line,
              transformValue transform: @escaping (Value) -> String = String.init(describing:),
              logger: @escaping Timelane.Logger = Timelane.defaultLogger) -> SignalProducer<Value, Error> {
        lift { $0.lane(name, filter: filter, transformValue: transform, logger: logger) }
    }
}
