//
//  Info.swift
//  
//
//  Created by Philip Turner on 10/24/22.
//

import COpenCL

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

func writeInfo_Int<T>(
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
