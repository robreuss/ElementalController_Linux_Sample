import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ElementController_Linux_SampleTests.allTests),
    ]
}
#endif