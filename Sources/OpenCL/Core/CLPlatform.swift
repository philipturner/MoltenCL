//
//  CLPlatform.swift
//
//
//  Created by Philip Turner on 10/23/22.
//

import COpenCL
import Metal

public class CLPlatform {
  // Internal so the user can't generate a custom platform.
  internal init() {
    // A device representing all GPUs on the platform. Either the universal
    // system device (M1) or one of many Mac2 GPUs on an Intel Mac. We only use
    // this device to query GPU family.
    let device = MTLCopyAllDevices().first!
    // MTLCreateSystemDefaultDevice() fails in command-line scripts, so use
    // MTLCopyAllDevices() instead.

    // Apple6 supports SIMD permute, but not SIMD reductions. The OpenCL
    // specification seems to demand supporting SIMD reductions if you support
    // anything SIMD at all. That makes it time-consuming to determine how to
    // support Apple6. I also don't have an Apple6 device to test. Therefore,
    // MoltenCL does not support Apple6.
    if device.supportsFamily(.apple6) && !device.supportsFamily(.apple7) {
      fatalError("A13 is not compatible with MoltenCL.")
    }

    // Only Apple7+ and Mac2 devices pass this test.
    guard device.supportsFamily(.metal3) else {
      fatalError("Metal device '\(device.name)' does not support Metal 3.")
    }
  }

  public static let `default` = CLPlatform()

  // Version v3.0.12, Thu, 15 Sep 2022 21:00:00 +0000:
  // 996a022a7ad45583591df5e665af0f8f38b85e83
  private static let _version: String = "OpenCL 3.0 (Sep 15 2022 21:00:00)"

  private static let _extensions: [String] = _extensionsWithVersion.map(\.name)

  // Version v3.0.12, Thu, 15 Sep 2022 21:00:00 +0000:
  // 996a022a7ad45583591df5e665af0f8f38b85e83
  private static let _numericVersion: CLVersion = .init(
    major: 3, minor: 0, patch: 12)

  private static let _extensionsWithVersion: [CLNameVersion] = {
    () -> [CLNameVersion] in
    // Versioning is mostly for provisional extensions and the DP4a instruction.
    // MoltenCL does not support any extensions with a version other than 1.0.0.
    let _1_0_0 = CLVersion(major: 1, minor: 0, patch: 0)

    var output: [(CLVersion, String)] = [
      (_1_0_0, "cl_khr_3d_image_writes"),
      (_1_0_0, "cl_khr_byte_addressable_store"),
      (_1_0_0, "cl_khr_create_command_queue"),
      (_1_0_0, "cl_khr_depth_images"),

      // OpenCL 2.0 requires exposing `MTLIndirectCommandBuffer` to the shader
      // code.
      (_1_0_0, "cl_khr_device_enqueue_local_arg_types"),

      // Use `MTLDevice.registryID` for a unique 8-byte ID, zero out the
      // remaining bytes.
      (_1_0_0, "cl_khr_device_uuid"),
      (_1_0_0, "cl_khr_extended_bit_ops"),
      (_1_0_0, "cl_khr_extended_versioning"),

      // `__builtin_expect` and `__builtin_assume` are callable from MSL, just
      // need to determine how they map to AIR
      (_1_0_0, "cl_khr_expect_assume"),
      (_1_0_0, "cl_khr_fp16"),

      // Need to finish the 'metal-float64' library, which emulates FP64 on
      // Apple silicon. If possible, utilize native FP64 on AMD GPUs.
      (_1_0_0, "cl_khr_fp64"),
      (_1_0_0, "cl_khr_global_int32_base_atomics"),
      (_1_0_0, "cl_khr_global_int32_extended_atomics"),
      (_1_0_0, "cl_khr_il_program"),
      (_1_0_0, "cl_khr_image2d_from_buffer"),
      (_1_0_0, "cl_khr_local_int32_base_atomics"),
      (_1_0_0, "cl_khr_local_int32_extended_atomics"),
      (_1_0_0, "cl_khr_mipmap_image"),
      (_1_0_0, "cl_khr_mipmap_image_writes"),
      (_1_0_0, "cl_khr_spir"),
      (_1_0_0, "cl_khr_srgb_image_writes"),

      // Original subgroup functions from `cl_khr_subgroups` are supposed to be
      // forbidden inside non-uniform control flow. However, I have no idea how
      // to enforce this. What happens when you enter such a function, with
      // non-uniform control flow? Does the compiler prevent it, or are the
      // results just undefined? MoltenCL will make no distinction between the
      // uniform and non-uniform versions of these functions.
      (_1_0_0, "cl_khr_subgroups"),
      (_1_0_0, "cl_khr_subgroup_ballot"),

      // Specification forces cluster size to be compile-time constant, so we
      // can implement sizes other than {4, simd_size} through emulation.
      (_1_0_0, "cl_khr_subgroup_clustered_reduce"),
      (_1_0_0, "cl_khr_subgroup_extended_types"),
      (_1_0_0, "cl_khr_subgroup_named_barrier"),
      (_1_0_0, "cl_khr_subgroup_non_uniform_arithmetic"),
      (_1_0_0, "cl_khr_subgroup_non_uniform_vote"),
      (_1_0_0, "cl_khr_subgroup_rotate"),
      (_1_0_0, "cl_khr_subgroup_shuffle"),
      (_1_0_0, "cl_khr_subgroup_shuffle_relative"),
      (_1_0_0, "cl_khr_terminate_context"),
    ]

    // Deviating from Apple's convention of capitalizing the word after `cl_`.
    // For example, Apple would have named these `cl_APPLE_subgroup_matrix`,
    // etc. MoltenCL uses lowercase to be more in-line with how other vendors
    // name extensions (e.g. `cl_intel_...`).
    let device = MTLCreateSystemDefaultDevice()!
    if device.supportsFamily(.apple7) {
      // SIMD-scoped matrix multiply operations
      output.append((_1_0_0, "cl_apple_subgroup_matrix"))
    }
    if device.supportsFamily(.apple8) {
      // SIMD shift and fill
      output.append((_1_0_0, "cl_apple_subgroup_shuffle_and_fill"))
    }
    return output.map { CLNameVersion(version: $0.0, name: $0.1) }
  }()

  // OpenCL 1.0

  public var profile: String { "FULL_PROFILE" }

  public var version: String { Self._version }

  public var name: String { "Apple" }

  public var vendor: String { "Apple" }

  public var extensions: [String] { Self._extensions }

  // OpenCL 2.1

  // Safe to assume CPU timer is in nanoseconds, but not safe to assume GPU
  // timer is in nanonseconds:
  // https://developer.apple.com/documentation/metal/performance_tuning/correlating_cpu_and_gpu_timestamps
  //
  // Through experiments, GPU and CPU timer are perfectly synchronized on Apple
  // silicon, and match the number of nanoseconds that have passed. However,
  // granularity might be 41.67 ns on Apple silicon but 1 ns on Intel Macs:
  // https://eclecticlight.co/2020/11/27/inside-m1-macs-time-and-logs/
  public var hostTimerResolution: UInt64 {
    var info = mach_timebase_info()
    mach_timebase_info(&info)

    // On Apple silicon, truncates 41.67 to 41.
    return UInt64(info.numer / info.denom)
  }

  // OpenCL 3.0

  public var numericVersion: CLVersion { Self._numericVersion }

  // Returns the extensions with their version from the OpenCL Extension
  // Specification.
  public var extensionsWithVersion: [CLNameVersion] {
    Self._extensionsWithVersion
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
    platforms.pointee = .init(
      Unmanaged.passUnretained(CLPlatform.default).toOpaque())
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
  let platform: CLPlatform = Unmanaged.fromOpaque(.init(clPlatform))
    .takeUnretainedValue()

  switch Int32(bitPattern: param_name) {
  case CL_PLATFORM_PROFILE:
    return writeInfo_String(
      param_value_size, param_value, param_value_size_ret, platform.profile)
  case CL_PLATFORM_VERSION:
    return writeInfo_String(
      param_value_size, param_value, param_value_size_ret, platform.version)
  case CL_PLATFORM_NUMERIC_VERSION:
    return writeInfo_Int(
      param_value_size, param_value, param_value_size_ret,
      platform.numericVersion.version)
  case CL_PLATFORM_NAME:
    return writeInfo_String(
      param_value_size, param_value, param_value_size_ret, platform.name)
  case CL_PLATFORM_VENDOR:
    return writeInfo_String(
      param_value_size, param_value, param_value_size_ret, platform.vendor)
  case CL_PLATFORM_EXTENSIONS:
    return writeInfo_ArrayOfString(
      param_value_size, param_value, param_value_size_ret, platform.extensions)
  case CL_PLATFORM_EXTENSIONS_WITH_VERSION:
    return writeInfo_ArrayOfCLNameVersion(
      param_value_size, param_value, param_value_size_ret,
      platform.extensionsWithVersion)
  case CL_PLATFORM_HOST_TIMER_RESOLUTION:
    return writeInfo_Int(
      param_value_size, param_value, param_value_size_ret,
      platform.hostTimerResolution)
  default:
    return CL_INVALID_VALUE
  }
}
