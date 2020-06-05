import XCTest
@testable import TimelaneCore
import TimelaneCoreTestUtils
import ReactiveSwift
@testable import ReactiveTimelane

@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
final class SignalTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
        super.setUp()
    }
    
    // MARK: - Events
    
    func testCompletedEvent() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        let (signal, observer) = Signal<Never, Never>.pipe()
        signal
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .observe { _ in }
        observer.sendCompleted()
        
        XCTAssertEqual(recorder.logged.count, 1)
        XCTAssertEqual(recorder.logged[0].type, "Completed")
        XCTAssertEqual(recorder.logged[0].subscription, "Test Subscription")
    }
    
    func testValueEvents() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        let (signal, observer) = Signal<Int, Never>.pipe()
        signal
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .observe { _ in }
        observer.send(value: 1)
        observer.send(value: 2)
        observer.send(value: 3)
        observer.sendCompleted()
        
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
        
        let (signal, observer) = Signal<Int, Never>.pipe()
        signal
            .lane("Test Subscription",
                  filter: .event,
                  transformValue: { "TEST \($0)" },
                  logger: recorder.log)
            .observe { _ in }
        observer.send(value: 1)
        observer.sendCompleted()
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
        
        let (signal, observer) = Signal<Never, TestError>.pipe()
        signal
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .observe { _ in }
        observer.send(error: .somethingWentWrong)
        XCTAssertEqual(recorder.logged.count, 1)
        XCTAssertEqual(recorder.logged[0].type, "Error")
        XCTAssertEqual(recorder.logged[0].value, TestError.somethingWentWrong.errorDescription)
    }
    
    func testErrorEventAfterValues() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        let (signal, observer) = Signal<Int, TestError>.pipe()
        signal
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .observe { _ in }
        observer.send(value: 1)
        observer.send(value: 2)
        observer.send(value: 3)
        observer.send(error: .somethingWentWrong)
        
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
        
        let (signal, observer) = Signal<Int, Never>.pipe()
        signal
            .lane("Test Subscription", filter: .event, logger: recorder.log)
            .observe { _ in }
        
        observer.send(value: 0)
        
        XCTAssertEqual(recorder.logged.count, 1)
        XCTAssertEqual(recorder.logged[0].outputTldr, "Output, Test Subscription, 0")
        
        observer.sendInterrupted()
        
        XCTAssertEqual(recorder.logged.count, 2)
        XCTAssertEqual(recorder.logged[1].type, "Cancelled")
    }
    
    // MARK: - Subscription
    
    func testSubscription() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        let (signal, observer) = Signal<Int, Never>.pipe()
        signal
            .lane("Test Subscription", filter: .subscription, logger: recorder.log)
            .observe { _ in }
        
        XCTAssertEqual(recorder.logged.count, 1)
        XCTAssertEqual(recorder.logged[0].signpostType, "begin")
        XCTAssertEqual(recorder.logged[0].subscribe, "Test Subscription")
        
        observer.sendCompleted()
        
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
