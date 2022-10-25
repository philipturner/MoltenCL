import XCTest
import COpenCL
import OpenCL

final class OpenCLTests: XCTestCase {
    func testExample() throws {
        var numPlatforms: UInt32 = 0
        clGetPlatformIDs(0, nil, &numPlatforms)
        XCTAssertEqual(numPlatforms, 1)
        
        withUnsafeTemporaryAllocation(
            of: cl_platform_id?.self, capacity: 1
        ) { bufferPointer in
            clGetPlatformIDs(1, bufferPointer.baseAddress, nil)
            XCTAssertNotEqual(Int(bitPattern: bufferPointer[0]), 0)
        }
    }
}
