//
//  main.swift
//  
//
//  Created by Philip Turner on 10/23/22.
//

import Foundation

let path = "\(FileManager.default.currentDirectoryPath)/libOpenCL.dylib"
print(path)

let libOpenCL = dlopen(path, RTLD_LAZY | RTLD_GLOBAL)
guard let libOpenCL = libOpenCL else {
    print("OpenCL library could not be loaded")
    print(String(cString: dlerror()))
    exit(-1)
}
print("Loaded OpenCL library")

let symbol = dlsym(libOpenCL, "clGetPlatformIDs")
guard let symbol = symbol else {
    print("Symbol could not be loaded")
    print(String(cString: dlerror()))
    exit(-1)
}
print("Loaded symbol")

typealias SymbolType = @convention(c) (
    UInt32, UnsafeMutablePointer<OpaquePointer?>?, UnsafeMutablePointer<UInt32>?) -> Int32
let clGetPlatformIDs = unsafeBitCast(symbol, to: SymbolType.self)

var numPlatforms: UInt32 = 0
_ = clGetPlatformIDs(0, nil, &numPlatforms)
precondition(numPlatforms == 1, "Number of platforms not 1.")

withUnsafeTemporaryAllocation(
    of: OpaquePointer?.self, capacity: 1
) { bufferPointer in
    _ = clGetPlatformIDs(1, bufferPointer.baseAddress, nil)
    precondition(bufferPointer[0] != nil, "Retrieved platform was nil.")
}
print("Successfully checked platforms")
