#if os(Linux)

import XCTest
@testable import AppTests

XCTMain([
    // AppLogicTests
    testCase(RouteTests.allTests),
])

#endif