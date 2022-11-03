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

  public init(
    mtlDevice: MTLDevice
  ) {
    self.mtlDevice = mtlDevice
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
