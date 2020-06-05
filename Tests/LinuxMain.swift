import XCTest
import ReactiveTimelaneTests

var tests = [XCTestCaseEntry]()
tests += SignalTests.allTests()
tests += SignalProducerTests.allTests()
tests += LifetimeTests.allTests()
XCTMain(tests)
