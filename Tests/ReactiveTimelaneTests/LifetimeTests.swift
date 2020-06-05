import XCTest
@testable import TimelaneCore
import TimelaneCoreTestUtils
import ReactiveSwift
@testable import ReactiveTimelane

@available(macOS 10.14, iOS 12, tvOS 12, watchOS 5, *)
final class LifetimeTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
        super.setUp()
    }
    
    // MARK: - Subscription
    
    func testSubscription() {
        let recorder = TestLog()
        Timelane.Subscription.didEmitVersion = true
        
        let (lifetime, token) = Lifetime.make()
        lifetime
            .lane("Test Subscription", logger: recorder.log)
        
        XCTAssertEqual(recorder.logged.count, 1)
        XCTAssertEqual(recorder.logged[0].signpostType, "begin")
        XCTAssertEqual(recorder.logged[0].subscribe, "Test Subscription")
        
        token.dispose()
        
        XCTAssertEqual(recorder.logged[1].signpostType, "end")
    }
    
    // MARK: - All tests
    
    static var allTests = [
        ("testSubscription", testSubscription),
    ]
}
