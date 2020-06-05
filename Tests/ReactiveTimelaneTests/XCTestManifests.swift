import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SignalTests.allTests),
        testCase(SignalProducerTests.allTests),
        testCase(LifetimeTests.allTests),
    ]
}
#endif
