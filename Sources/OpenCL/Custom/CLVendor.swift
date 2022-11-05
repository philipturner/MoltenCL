//
//  CLVendor.swift
//
//
//  Created by Philip Turner on 11/4/22.
//

import COpenCL
import Metal

// Internal enumeration for dealing with vendor-specific quirks.
enum CLVendor {
  case apple
  case intel
  case amd

  init(
    mtlDevice: MTLDevice
  ) {
    #if arch(arm64)
      self = .apple
    #else
      if mtlDevice.isLowPower {
        self = .intel
      } else {
        self = .amd
      }
    #endif
  }
}
