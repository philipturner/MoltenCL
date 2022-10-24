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
}

// MARK: - C API

@_cdecl("clGetPlatformIDs")
@discardableResult
public func clGetPlatformIDs(
    _ num_entries: UInt32,
    _ platforms: UnsafeMutablePointer<cl_platform_id>?,
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
    _ platform: cl_platform_id,
    _ param_name: cl_platform_info,
    _ param_value_size: Int,
    _ param_value: UnsafeMutableRawPointer?,
    _ param_value_size_ret: UnsafeMutablePointer<Int>?
) -> Int32 {
    let clPlatform = platform
    let platform: CLPlatform = Unmanaged.fromOpaque(.init(clPlatform)).takeUnretainedValue()
    // TODO
    return CL_SUCCESS
}
