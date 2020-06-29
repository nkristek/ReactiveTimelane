import XCTest
@testable import TimelaneCore
import TimelaneCoreTestUtils
import ReactiveSwift
@testable import ReactiveTimelane

@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
final class DoubleColonBug: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
        super.setUp()
    }
    
    func testPassing() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        SignalProducer(value: 1)
            .lane("Test Subscription",
                  filter: .event,
                  transformValue: { "TEST \($0)" },
                  logger: recorder.log)
            .start()
        
        XCTAssertEqual(recorder.logged.count, 2)
        XCTAssertEqual(recorder.logged[0].outputTldr, "Output, Test Subscription, TEST 1")
    }
    
    func testFailing() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        SignalProducer(value: 1)
            .lane("Test Subscription",
                  filter: .event,
                  transformValue: { "TEST: \($0)" },
                  logger: recorder.log)
            .start()
        
        XCTAssertEqual(recorder.logged.count, 2)
        XCTAssertEqual(recorder.logged[0].outputTldr, "Output, Test Subscription, TEST: 1")
    }
    
    // MARK: - All tests
    
    static var allTests = [
        ("testPassing", testPassing),
        ("testFailing", testFailing),
    ]
}
