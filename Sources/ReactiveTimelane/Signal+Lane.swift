import Foundation
import ReactiveSwift
import TimelaneCore

@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
public extension Signal {
    /**
     This operator logs the lifetime of the subscription to the `Signal` and its events to the Timelane Instrument.
     
     - Note: You can download the Timelane Instrument from [timelane.tools](http://timelane.tools).
     
     - Parameter name: A name for the lane when visualized in Instruments.
     
     - Parameter filter: Determines which metrics should be logged.
     
     - Parameter file: The name of the current file.
     
     - Parameter function: The name of the current function.
     
     - Parameter line: The number of the current line.
     
     - Parameter transformValue: An optional closure to format the subscription values for displaying in Instruments.
     
     - Parameter logger: A logger which should be used to log the specified metrics.
     
     - Returns: A `Signal` where the specified metrics are logged for the Timelane Instrument.
     */
    func lane(_ name: String,
              filter: Timelane.LaneTypeOptions = .all,
              file: StaticString = #file,
              function: StaticString = #function,
              line: UInt = #line,
              transformValue transform: @escaping (Value) -> String = String.init(describing:),
              logger: @escaping Timelane.Logger = Timelane.defaultLogger) -> Signal<Value, Error> {
        let fileName = file.description.components(separatedBy: "/").last!
        let source = "\(fileName):\(line) - \(function)"
        let subscription = Timelane.Subscription(name: name, logger: logger)
        
        if filter.contains(.subscription) {
            subscription.begin(source: source)
        }
        
        return on(
            failed: { error in
                if filter.contains(.subscription) {
                    subscription.end(state: .error(error.localizedDescription))
                }
                
                if filter.contains(.event) {
                    subscription.event(value: .error(error.localizedDescription), source: source)
                }
        }, completed: {
            if filter.contains(.subscription) {
                subscription.end(state: .completed)
            }
            
            if filter.contains(.event) {
                subscription.event(value: .completion, source: source)
            }
        }, interrupted: {
            if filter.contains(.subscription) {
                subscription.end(state: .cancelled)
            }
            
            if filter.contains(.event) {
                subscription.event(value: .cancelled, source: source)
            }
        }, value: { value in
            if filter.contains(.event) {
                subscription.event(value: .value(transform(value)), source: source)
            }
        })
    }
}
