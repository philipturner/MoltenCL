//
//  Platform.swift
//  
//
//  Created by Philip Turner on 10/23/22.
//

import Foundation

@_cdecl("clGetPlatformIDs")
public func clGetPlatformIDs(_ input: Int32) -> Int32 {
    return input
}
