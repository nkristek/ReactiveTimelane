import Foundation
import ReactiveSwift
import TimelaneCore

@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
public extension Lifetime {
    /**
     This operator logs the lifetime to the Timelane Instrument.
     
     - Note: You can download the Timelane Instrument from [timelane.tools](http://timelane.tools).
     
     - Parameter name: A name for the lane when visualized in Instruments.
     
     - Parameter file: The name of the current file.
     
     - Parameter function: The name of the current function.
     
     - Parameter line: The number of the current line.
     
     - Parameter logger: A logger which should be used to log the lifetime.
     */
    func lane(_ name: String,
              file: StaticString = #file,
              function: StaticString = #function,
              line: UInt = #line,
              logger: @escaping Timelane.Logger = Timelane.defaultLogger) {
        let fileName = file.description.components(separatedBy: "/").last!
        let source = "\(fileName):\(line) - \(function)"
        let subscription = Timelane.Subscription(name: name, logger: logger)
        subscription.begin(source: source)
        self += observeEnded {
            subscription.end(state: .completed)
        }
    }
}
