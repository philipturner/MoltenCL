//
//  CLVersion.swift
//
//
//  Created by Philip Turner on 10/24/22.
//

import COpenCL

public struct CLVersion: Comparable {
  // Using `UInt32` instead of `Int` to halve CPU register usage. Also, it's a
  // standard type to represent things across the OpenCL API. `cl_version` is
  // even a typealias of `UInt32`.
  public var major: UInt32
  public var minor: UInt32
  public var patch: UInt32?
  
  @_transparent
  public init(major: UInt32, minor: UInt32, patch: UInt32? = nil) {
    self.major = major
    self.minor = minor
    self.patch = patch
  }
  
  @inlinable
  public static func < (lhs: CLVersion, rhs: CLVersion) -> Bool {
    if lhs.major != rhs.major {
      return lhs.major < rhs.major
    }
    if lhs.minor != rhs.minor {
      return lhs.minor < rhs.minor
    }
    
    // Not having a patch is considered being "0" of the patch. If one side has
    // a patch and another doesn't, the versions will already be counted as not
    // equal. So determine a convention for comparing them.
    let lhsPatch = lhs.patch ?? 0
    let rhsPatch = rhs.patch ?? 0
    return lhsPatch < rhsPatch
  }
}

public struct CLNameVersion {
  public var version: CLVersion
  public var name: String
  
  @_transparent
  public init(version: CLVersion, name: String) {
    self.version = version
    self.name = name
  }
}

extension CLVersion {
  @usableFromInline static let majorBits = 10
  @usableFromInline static let minorBits = 10
  @usableFromInline static let patchBits = 12
  
  @usableFromInline static let majorMask: UInt32 = 1 << majorBits - 1
  @usableFromInline static let minorMask: UInt32 = 1 << minorBits - 1
  @usableFromInline static let patchMask: UInt32 = 1 << patchBits - 1
  
  @inlinable
  public init(version: cl_version) {
    major = version
    minor = version
    var patch = version
    
    // Vectorize the bitwise AND.
    major &= Self.majorMask << (Self.minorBits + Self.patchBits)
    minor &= Self.minorMask << Self.patchBits
    patch &= Self.patchMask
    
    major >>= Self.minorBits + Self.patchBits
    minor >>= Self.patchBits
    self.patch = patch
  }
  
  @inlinable
  public var version: cl_version {
    // Unwrapping of `patch` could induce a 1-cycle overhead, so waiting to
    // vectorize until later.
    var majorMask = major << (Self.minorBits + Self.patchBits)
    var minorMask = minor << Self.patchBits
    var patchMask = patch ?? 0
    
    // Vectorize the bitwise AND.
    majorMask &= Self.majorMask << (Self.minorBits + Self.patchBits)
    minorMask &= Self.minorMask << Self.patchBits
    patchMask &= Self.patchMask
    return majorMask | minorMask | patchMask
  }
}
