import XCTest
@testable import OpenCL

final class OpenCLTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(OpenCL().text, "Hello, World!")
    }
}
