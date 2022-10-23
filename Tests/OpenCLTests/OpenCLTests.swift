import XCTest
@testable import OpenCL

final class OpenCLTests: XCTestCase {
    func testExample() throws {
        print(FileManager.default.currentDirectoryPath)
        let path = "/Users/philipturner/Documents/GROMACS/MoltenCL/.build/arm64-apple-macosx/release/libOpenCL.dylib"
        let libOpenCL = dlopen(path, RTLD_LAZY | RTLD_GLOBAL)
        print(libOpenCL)
//        XCTAssertEqual(clGetPlatformIDs(2), 2)
    }
}
