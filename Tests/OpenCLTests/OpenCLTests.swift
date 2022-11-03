import COpenCL
import OpenCL
import XCTest

final class OpenCLTests: XCTestCase {
  func testExample() throws {
    // clGetPlatformIDs

    var numPlatforms: UInt32 = 0
    clGetPlatformIDs(0, nil, &numPlatforms)
    XCTAssertEqual(numPlatforms, 1)

    var platform: cl_platform_id?
    withUnsafeTemporaryAllocation(
      of: cl_platform_id?.self, capacity: 1
    ) { bufferPointer in
      clGetPlatformIDs(1, bufferPointer.baseAddress, nil)
      XCTAssertNotEqual(Int(bitPattern: bufferPointer[0]), 0)
      platform = bufferPointer[0]
    }
    guard let platform = platform else {
      fatalError("This should never happen.")
    }

    // CL_PLATFORM_EXTENSIONS

    var extensionsSize: Int = 0
    clGetPlatformInfo(
      platform, UInt32(CL_PLATFORM_EXTENSIONS), 0, nil, &extensionsSize)
    XCTAssertGreaterThan(extensionsSize, 0)

    withUnsafeTemporaryAllocation(
      of: CChar.self, capacity: extensionsSize
    ) { bufferPointer in
      clGetPlatformInfo(
        platform, UInt32(CL_PLATFORM_EXTENSIONS), extensionsSize,
        bufferPointer.baseAddress, nil)
      let extensionsString = String(validatingUTF8: bufferPointer.baseAddress!)!
      XCTAssert(extensionsString.contains("cl_khr_depth_images"))
    }

    // CL_PLATFORM_EXTENSIONS_WITH_VERSION

    var extensionsWithVersionSize: Int = 0
    clGetPlatformInfo(
      platform, UInt32(CL_PLATFORM_EXTENSIONS_WITH_VERSION), 0, nil,
      &extensionsWithVersionSize)
    XCTAssertGreaterThan(extensionsWithVersionSize, 0)

    let clNameVersionStride = MemoryLayout<cl_name_version>.stride
    XCTAssertEqual(extensionsWithVersionSize % clNameVersionStride, 0)

    withUnsafeTemporaryAllocation(
      of: cl_name_version.self,
      capacity: extensionsWithVersionSize / clNameVersionStride
    ) { bufferPointer in
      clGetPlatformInfo(
        platform, UInt32(CL_PLATFORM_EXTENSIONS_WITH_VERSION),
        extensionsWithVersionSize,
        bufferPointer.baseAddress, nil)

      XCTAssertEqual(
        bufferPointer[0].version, CLVersion(major: 1, minor: 0).version)

      let stringPtr1 = UnsafeRawPointer(bufferPointer.baseAddress!) + 4
      let stringPtr2 = stringPtr1.assumingMemoryBound(to: CChar.self)
      let extensionsString = String(cString: stringPtr2)
      XCTAssert(extensionsString.contains("cl_khr_"), extensionsString)
    }
  }
}
