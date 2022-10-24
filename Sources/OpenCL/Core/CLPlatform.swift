//
//  CLPlatform.swift
//  
//
//  Created by Philip Turner on 10/23/22.
//

import COpenCL
import Foundation

public class CLPlatform {
    init() {
        
    }
    
    public static let `default` = CLPlatform()
    
    // OpenCL 1.0
    
    @inline(__always)
    var profile: String {
        "FULL_PROFILE"
    }
    
    @inline(__always)
    var version: String {
        // Version v3.0.12, Thu, 15 Sep 2022 21:00:00 +0000: 996a022a7ad45583591df5e665af0f8f38b85e83
        "OpenCL 3.0 (Sep 15 2022 21:00:00)"
    }
    
    @inline(__always)
    var name: String {
        "Apple"
    }
    
    @inline(__always)
    var vendor: String {
        "Apple"
    }
    
    // OpenCL 3.0
    
    @inline(__always)
    var numericVersion: CLVersion {
        // Version v3.0.12, Thu, 15 Sep 2022 21:00:00 +0000: 996a022a7ad45583591df5e665af0f8f38b85e83
        CLVersion(major: 3, minor: 0, patch: 12)
    }
}

// MARK: - C API

@_cdecl("clGetPlatformIDs")
@discardableResult
public func clGetPlatformIDs(
    _ num_entries: UInt32,
    _ platforms: UnsafeMutablePointer<cl_platform_id?>?,
    _ num_platforms: UnsafeMutablePointer<UInt32>?
) -> Int32 {
    if platforms == nil, num_platforms == nil {
        return CL_INVALID_VALUE
    }
    if let platforms = platforms {
        guard num_entries > 0 else {
            return CL_INVALID_VALUE
        }
        platforms.pointee = .init(Unmanaged.passUnretained(CLPlatform.default).toOpaque())
    }
    if let num_platforms = num_platforms {
        num_platforms.pointee = 1
    }
    return CL_SUCCESS
}

@_cdecl("clGetPlatformInfo")
@discardableResult
public func clGetPlatformInfo(
    _ platform: cl_platform_id?,
    _ param_name: cl_platform_info,
    _ param_value_size: Int,
    _ param_value: UnsafeMutableRawPointer?,
    _ param_value_size_ret: UnsafeMutablePointer<Int>?
) -> Int32 {
    guard let clPlatform = platform else {
        return CL_INVALID_PLATFORM
    }
    let platform: CLPlatform = Unmanaged.fromOpaque(.init(clPlatform)).takeUnretainedValue()
    
    switch Int32(bitPattern: param_name) {
    case CL_PLATFORM_PROFILE:
        return writeInfo_String(
            param_value_size, param_value, param_value_size_ret, platform.profile)
    case CL_PLATFORM_VERSION:
        return writeInfo_String(
            param_value_size, param_value, param_value_size_ret, platform.version)
    case CL_PLATFORM_NUMERIC_VERSION:
        return writeInfo_Int(
            param_value_size, param_value, param_value_size_ret, platform.numericVersion)
    case CL_PLATFORM_NAME:
        return writeInfo_String(
            param_value_size, param_value, param_value_size_ret, platform.name)
    case CL_PLATFORM_VENDOR:
        return writeInfo_String(
            param_value_size, param_value, param_value_size_ret, platform.vendor)
    case CL_PLATFORM_EXTENSIONS:
        // TODO: Implement
        return CL_INVALID_VALUE
    case CL_PLATFORM_EXTENSIONS_WITH_VERSION:
        // TODO: Implement
        return CL_INVALID_VALUE
    case CL_PLATFORM_HOST_TIMER_RESOLUTION:
        // TODO: Implement
        return CL_INVALID_VALUE
    default:
        return CL_INVALID_VALUE
    }
}
