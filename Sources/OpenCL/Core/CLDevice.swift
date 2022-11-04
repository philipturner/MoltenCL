//
//  CLDevice.swift
//
//
//  Created by Philip Turner on 11/3/22.
//

import COpenCL
import Metal

public class CLDevice {
  public let mtlDevice: MTLDevice
  public var referenceCount: Int

  public init(
    mtlDevice: MTLDevice
  ) {
    self.mtlDevice = mtlDevice
    self.referenceCount = 0
  }

  public static let `default`: CLDevice = {
    // Crash if the computer doesn't support Metal 3.
    _ = CLPlatform.default

    if let device = MTLCreateSystemDefaultDevice() {
      return CLDevice(mtlDevice: device)
    } else {
      // In a command-line application, have to guess the best device.
      var bestCandidate: MTLDevice?
      for device in MTLCopyAllDevices() {
        // Check whether it's an Intel integrated GPU.
        if device.isLowPower {
          if bestCandidate == nil {
            // At least put some GPU as the candidate.
            bestCandidate = device
          }
        } else {
          // Either an Apple or AMD GPU.
          bestCandidate = device
        }
      }

      guard let bestCandidate = bestCandidate else {
        fatalError("No Metal device found.")
      }
      return CLDevice(mtlDevice: bestCandidate)
    }
  }()
}

extension CLDevice {
  // OpenCL 1.0

  public var type: CLDeviceType {
    if mtlDevice === CLDevice.default.mtlDevice {
      return [.gpu, .default]
    } else {
      return .gpu
    }
  }

  public var vendorID: UInt32 {
    // Obtained from `clinfo`
    0x1027f00
  }

  public var maxComputeUnits: UInt32 {
    // TODO: On macOS, use an external process that calls into Apple's OpenCL
    // driver. This will avoid name conflicts with MoltenCL's "libOpenCL.dylib"
    // library, unless it's renamed to "libMoltenCL.dylib". Cache the value for
    // future use.

    // TODO: On iOS, use DeviceKit to find the model. That provides enough info
    // to fully resolve GPU core count.
    fatalError("\(#function) not implemented.")
  }

  public var maxWorkItemDimensions: UInt32 {
    3
  }

  public var maxWorkItemSizes: [Int] {
    let size = mtlDevice.maxThreadsPerThreadgroup
    return [size.width, size.height, size.depth]
  }
}

// MARK: - C API

@_cdecl("clGetDeviceIDs")
@discardableResult
public func clGetDeviceIDs(
  _ platform: cl_platform_id?,
  _ device_type: cl_device_type,
  _ num_entries: UInt32,
  _ devices: UnsafeMutablePointer<cl_device_id?>?,
  _ num_devices: UnsafeMutablePointer<UInt32>?
) -> Int32 {
  guard let clPlatform = platform else {
    return CL_INVALID_PLATFORM
  }
  let platform: CLPlatform = Unmanaged.fromOpaque(.init(clPlatform))
    .takeUnretainedValue()

  let type = CLDeviceType(rawValue: device_type)
  if type != .all && type.contains(.custom) {
    guard type == [] else {
      return CL_INVALID_DEVICE_TYPE
    }
  }
  let clDevices = platform.devices(type: type)
  guard clDevices.count > 0 else {
    return CL_DEVICE_NOT_FOUND
  }

  if devices == nil, num_devices == nil {
    return CL_INVALID_VALUE
  }
  if let devices = devices {
    guard num_entries > 0 else {
      return CL_INVALID_VALUE
    }
    for i in 0..<min(Int(num_entries), clDevices.count) {
      let clDevice = clDevices[i]
      devices[i] = .init(Unmanaged.passUnretained(clDevice).toOpaque())
    }
  }
  if let num_devices = num_devices {
    num_devices.pointee = UInt32(clDevices.count)
  }
  return CL_SUCCESS
}

@_cdecl("clGetDeviceInfo")
@discardableResult
public func clGetDeviceInfo(
  _ device: cl_device_id?,
  _ param_name: cl_device_info,
  _ param_value_size: Int,
  _ param_value: UnsafeMutableRawPointer?,
  _ param_value_size_ret: UnsafeMutablePointer<Int>?
) -> Int32 {
  guard let clDevice = device else {
    return CL_INVALID_DEVICE
  }
  let device: CLDevice = Unmanaged.fromOpaque(.init(clDevice))
    .takeUnretainedValue()

  switch Int32(bitPattern: param_name) {
  case CL_DEVICE_TYPE:
    return writeInfo_Int(
      param_value_size, param_value, param_value_size_ret, device.type.rawValue)
  case CL_DEVICE_VENDOR_ID:
    return writeInfo_Int(
      param_value_size, param_value, param_value_size_ret, device.vendorID)
  case CL_DEVICE_MAX_COMPUTE_UNITS:
    return writeInfo_Int(
      param_value_size, param_value, param_value_size_ret,
      device.maxComputeUnits)
  case CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS:
    return writeInfo_Int(
      param_value_size, param_value, param_value_size_ret,
      device.maxComputeUnits)
  case CL_DEVICE_MAX_WORK_ITEM_SIZES:
    return writeInfo_ArrayOfInt(
      param_value_size, param_value, param_value_size_ret,
      device.maxWorkItemSizes)
  default:
    return CL_INVALID_VALUE
  }
}
