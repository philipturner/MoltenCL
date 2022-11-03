//
//  Info.swift
//
//
//  Created by Philip Turner on 10/24/22.
//

import COpenCL

func writeInfo_Int<T: BinaryInteger>(
  _ param_value_size: Int,
  _ param_value: UnsafeMutableRawPointer?,
  _ param_value_size_ret: UnsafeMutablePointer<Int>?,
  _ value: T
) -> Int32 {
  let value_size = MemoryLayout<T>.stride
  if let param_value_size_ret = param_value_size_ret {
    param_value_size_ret.pointee = value_size
  }
  if let param_value = param_value {
    if param_value_size < value_size {
      return CL_INVALID_VALUE
    }
    param_value.assumingMemoryBound(to: T.self).pointee = value
  }
  return CL_SUCCESS
}

func writeInfo_String(
  _ param_value_size: Int,
  _ param_value: UnsafeMutableRawPointer?,
  _ param_value_size_ret: UnsafeMutablePointer<Int>?,
  _ value: String
) -> Int32 {
  return value.utf8CString.withUnsafeBufferPointer { value_buffer_ptr in
    if let param_value_size_ret = param_value_size_ret {
      param_value_size_ret.pointee = value_buffer_ptr.count
    }
    if let param_value = param_value {
      if param_value_size < value_buffer_ptr.count {
        return CL_INVALID_VALUE
      }
      strcpy(param_value, value_buffer_ptr.baseAddress)
    }
    return CL_SUCCESS
  }
}

func writeInfo_ArrayOfString(
  _ param_value_size: Int,
  _ param_value: UnsafeMutableRawPointer?,
  _ param_value_size_ret: UnsafeMutablePointer<Int>?,
  _ value: [String]
) -> Int32 {
  // One extra space between strings, plus the null terminator.
  let value_size = value.reduce(0) { $0 + $1.count + 1 }
  if let param_value_size_ret = param_value_size_ret {
    param_value_size_ret.pointee = value_size
  }
  if let param_value = param_value {
    if param_value_size < value_size {
      return CL_INVALID_VALUE
    }
    var byteStream = param_value.assumingMemoryBound(to: CChar.self)
    let space: CChar = .init(Character(" ").asciiValue!)

    for element in value {
      element.utf8CString.withUnsafeBytes {
        _ = memcpy(byteStream, $0.baseAddress, element.count)
      }
      byteStream[element.count] = space
      byteStream += element.count + 1
    }

    if value.count > 0 {
      byteStream[-1] = 0  // null terminator
    }
  }
  return CL_SUCCESS
}

func writeInfo_ArrayOfCLNameVersion(
  _ param_value_size: Int,
  _ param_value: UnsafeMutableRawPointer?,
  _ param_value_size_ret: UnsafeMutablePointer<Int>?,
  _ value: [CLNameVersion]
) -> Int32 {
  let value_size = value.count * MemoryLayout<cl_name_version>.stride
  if let param_value_size_ret = param_value_size_ret {
    param_value_size_ret.pointee = value_size
  }
  if let param_value = param_value {
    if param_value_size < value_size {
      return CL_INVALID_VALUE
    }
    var byteStream = param_value
    let nameOffset = MemoryLayout<cl_name_version>.offset(of: \.name)!

    for element in value {
      precondition(
        element.name.count < CL_NAME_VERSION_MAX_NAME_SIZE,
        "Null-terminated string exceeds maximum size \(CL_NAME_VERSION_MAX_NAME_SIZE)."
      )
      let version_ptr = byteStream.assumingMemoryBound(to: UInt32.self)
      let name_ptr = (byteStream + nameOffset).assumingMemoryBound(
        to: CChar.self)
      version_ptr.pointee = element.version.version
      strcpy(name_ptr, element.name)

      // Did not zero out the bytes [4 + element.name.count + 1, 68]
      byteStream += MemoryLayout<cl_name_version>.stride
    }
  }
  return CL_SUCCESS
}
