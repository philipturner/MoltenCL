//
//  ValidateLibrary.swift
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

typealias SymbolType = @convention(c) (Int32) -> Int32
let clGetPlatformIDs = unsafeBitCast(symbol, to: SymbolType.self)
precondition(clGetPlatformIDs(2) == 2, "Function not working correctly")
print("Function working correctly")
