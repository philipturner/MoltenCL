//
//  CLPlatform.swift
//  
//
//  Created by Philip Turner on 10/23/22.
//

import COpenCL
import Foundation

public class CLPlatform {
    // Internal so the user can't generate a custom platform.
    internal init() {
        
    }
    
    public static let `default` = CLPlatform()
    
    // Version v3.0.12, Thu, 15 Sep 2022 21:00:00 +0000: 996a022a7ad45583591df5e665af0f8f38b85e83
    private static let _version: String = "OpenCL 3.0 (Sep 15 2022 21:00:00)"
    
    private static let _extensions: [String] = { () -> [String] in
        var output: [String] = [
            // If I don't yet know whether an extension is possible, it is commented out.
            "cl_khr_3d_image_writes",
//            "cl_khr_async_work_group_copy_fence",
            "cl_khr_byte_addressable_store",
            "cl_khr_create_command_queue",
            "cl_khr_depth_images",
//            "cl_khr_device_enqueue_local_arg_types",
            "cl_khr_device_uuid",
            "cl_khr_extended_async_copies",
            "cl_khr_extended_bit_ops",
            "cl_khr_extended_versioning",
            "cl_khr_expect_assume",
            "cl_khr_fp16",
            "cl_khr_fp64",
            "cl_khr_global_int32_base_atomics",
            "cl_khr_global_int32_extended_atomics",
            "cl_khr_il_program",
            "cl_khr_image2d_from_buffer",
//            "cl_khr_initialize_memory",
            "cl_khr_local_int32_base_atomics",
            "cl_khr_local_int32_extended_atomics",
            "cl_khr_integer_dot_product", // implement through mad24 or 16-bit multiply
        ]
        
        #if arch(arm64)
        // TODO: Check whether default device supports 'Apple7' instead.
        output.append("cl_APPLE_simdgroup_matrix")
        #endif
        return output
    }()
    
    // Version v3.0.12, Thu, 15 Sep 2022 21:00:00 +0000: 996a022a7ad45583591df5e665af0f8f38b85e83
    private static let _numericVersion: CLVersion = .init(major: 3, minor: 0, patch: 12)
    
    private static let _extensionsWithVersion: [CLNameVersion] =
        _extensions.map { CLNameVersion(version: _numericVersion, name: $0) }
    
    // OpenCL 1.0
    
    public var profile: String { "FULL_PROFILE" }
    
    public var version: String { Self._version }
    
    public var name: String { "Apple" }
    
    public var vendor: String { "Apple" }
    
    public var extensions: [String] { Self._extensions }
    
    // OpenCL 2.1
    
    // Safe to assume CPU timer is in nanoseconds, but not safe to assume GPU timer is in nanonseconds:
    // https://developer.apple.com/documentation/metal/performance_tuning/correlating_cpu_and_gpu_timestamps
    // Through experiments, GPU and CPU timer are perfectly synchronized on Apple silicon, and match
    // the number of nanoseconds that have passed. However, granularity might be 41.67 ns on Apple
    // silicon but 1 ns on Intel Macs: https://eclecticlight.co/2020/11/27/inside-m1-macs-time-and-logs/
    public var hostTimerResolution: UInt64 {
        var info = mach_timebase_info()
        mach_timebase_info(&info)
        return UInt64(info.numer / info.denom) // On Apple silicon, truncates 41.67 to 41.
    }
    
    // OpenCL 3.0
    
    public var numericVersion: CLVersion { Self._numericVersion }
    
    // TODO: Determine what the 'version' in this 'cl_name_version' represents
    public var extensionsWithVersion: [CLNameVersion] { Self._extensionsWithVersion }
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
        return writeInfo_Int(
            param_value_size, param_value, param_value_size_ret, platform.hostTimerResolution)
    default:
        return CL_INVALID_VALUE
    }
}
