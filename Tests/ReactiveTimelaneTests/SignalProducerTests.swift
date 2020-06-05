import XCTest
@testable import TimelaneCore
import TimelaneCoreTestUtils
import ReactiveSwift
@testable import ReactiveTimelane

@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
final class SignalProducerTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
        super.setUp()
    }
    
    // MARK: - Events
    
    func testCompletedEvent() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        SignalProducer<Never, Never> { observer, _ in observer.sendCompleted() }
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .start()
        
        XCTAssertEqual(recorder.logged.count, 1)
        XCTAssertEqual(recorder.logged[0].type, "Completed")
        XCTAssertEqual(recorder.logged[0].subscription, "Test Subscription")
    }
    
    func testValueEvents() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        SignalProducer(values: 1, 2, 3)
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .start()
        
        XCTAssertEqual(recorder.logged.count, 4)
        XCTAssertEqual(recorder.logged[0].outputTldr, "Output, Test Subscription, 1")
        XCTAssertEqual(recorder.logged[1].outputTldr, "Output, Test Subscription, 2")
        XCTAssertEqual(recorder.logged[2].outputTldr, "Output, Test Subscription, 3")
        XCTAssertEqual(recorder.logged[3].type, "Completed")
        XCTAssertEqual(recorder.logged[3].subscription, "Test Subscription")
    }
    
    func testFormatting() {
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
    
    enum TestError: LocalizedError {
        case somethingWentWrong
        var errorDescription: String? { "Error description" }
    }
    
    func testErrorEvent() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        SignalProducer<Never, TestError>(error: .somethingWentWrong)
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .start()
        
        XCTAssertEqual(recorder.logged.count, 1)
        XCTAssertEqual(recorder.logged[0].type, "Error")
        XCTAssertEqual(recorder.logged[0].value, TestError.somethingWentWrong.errorDescription)
    }
    
    func testErrorEventAfterValues() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        SignalProducer<Int, TestError>(values: 1, 2, 3)
            .concat(error: .somethingWentWrong)
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .start()
        
        XCTAssertEqual(recorder.logged.count, 4)
        XCTAssertEqual(recorder.logged[0].outputTldr, "Output, Test Subscription, 1")
        XCTAssertEqual(recorder.logged[1].outputTldr, "Output, Test Subscription, 2")
        XCTAssertEqual(recorder.logged[2].outputTldr, "Output, Test Subscription, 3")
        XCTAssertEqual(recorder.logged[3].type, "Error")
        XCTAssertEqual(recorder.logged[3].value, TestError.somethingWentWrong.errorDescription)
    }
    
    func testCancelledEvent() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        let property = MutableProperty(0)
        let disposable = property.producer
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .start()
        
        XCTAssertEqual(recorder.logged.count, 1)
        XCTAssertEqual(recorder.logged[0].outputTldr, "Output, Test Subscription, 0")
        
        disposable.dispose()
        
        XCTAssertEqual(recorder.logged.count, 2)
        XCTAssertEqual(recorder.logged[1].type, "Cancelled")
    }
    
    // MARK: - Subscription

    func testSubscription() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        let property = MutableProperty(0)
        let disposable = property.producer
            .lane("Test Subscription", filter: .subscription, logger: recorder.log)
            .start()
        
        XCTAssertEqual(recorder.logged.count, 1)
        XCTAssertEqual(recorder.logged[0].signpostType, "begin")
        XCTAssertEqual(recorder.logged[0].subscribe, "Test Subscription")
        
        disposable.dispose()
        
        XCTAssertEqual(recorder.logged[1].signpostType, "end")
    }
    
    // MARK: - All tests

    static var allTests = [
        ("testCompletedEvent", testCompletedEvent),
        ("testValueEvents", testValueEvents),
        ("testFormatting", testFormatting),
        ("testErrorEvent", testErrorEvent),
        ("testErrorEventAfterValues", testErrorEventAfterValues),
        ("testCancelledEvent", testCancelledEvent),
        ("testSubscription", testSubscription),
    ]
}
