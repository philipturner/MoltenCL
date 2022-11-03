//
//  CLBitField.swift
//
//
//  Created by Philip Turner on 6/22/22.
//

import COpenCL

protocol CLMacro: RawRepresentable where RawValue: BinaryInteger {}
extension CLMacro {
  init(
    _ macro: Int32
  ) {
    self.init(rawValue: RawValue(macro))!
  }
}

protocol CLEnum: CLMacro, CaseIterable {}

protocol CLBitField: CLMacro, OptionSet {}
extension CLBitField {
  init(
    _ macro: Int32
  ) {
    self.init(rawValue: RawValue(macro))
  }
}

public struct CLDeviceType: CLBitField {
  public let rawValue: cl_device_type
  public init(
    rawValue: cl_device_type
  ) {
    self.rawValue = rawValue
  }

  public static let `default` = Self(CL_DEVICE_TYPE_DEFAULT)
  public static let cpu = Self(CL_DEVICE_TYPE_CPU)
  public static let gpu = Self(CL_DEVICE_TYPE_GPU)
  public static let accelerator = Self(CL_DEVICE_TYPE_ACCELERATOR)
  public static let custom = Self(CL_DEVICE_TYPE_CUSTOM)

  // This type's raw value (0xFFFFFFFF) fills all bits, encompassing all
  // possible device types. Do not treat it like a unique device type.
  //
  // Because the `CL_DEVICE_TYPE_ALL` is larger than `Int32.max`, Swift imports
  // it as `UInt32`. This prevents me from initializing it like other device
  // types.
  public static let all = Self(rawValue: RawValue(CL_DEVICE_TYPE_ALL))
}

public struct CLDeviceFloatingPointConfig: CLBitField {
  public let rawValue: cl_device_fp_config
  public init(
    rawValue: cl_device_fp_config
  ) {
    self.rawValue = rawValue
  }

  public static let denorm = Self(CL_FP_DENORM)
  public static let infNaN = Self(CL_FP_INF_NAN)
  public static let roundToNearest = Self(CL_FP_ROUND_TO_NEAREST)
  public static let roundToZero = Self(CL_FP_ROUND_TO_ZERO)
  public static let roundToInf = Self(CL_FP_ROUND_TO_INF)
  public static let fma = Self(CL_FP_FMA)
  public static let softFloat = Self(CL_FP_SOFT_FLOAT)
  public static let correctlyRoundedDivideSqrt = Self(
    CL_FP_CORRECTLY_ROUNDED_DIVIDE_SQRT)
}

public struct CLDeviceMemoryCacheType: CLBitField {
  public let rawValue: cl_device_mem_cache_type
  public init(
    rawValue: cl_device_mem_cache_type
  ) {
    self.rawValue = rawValue
  }

  public static let none = Self(CL_NONE)
  public static let readOnlyCache = Self(CL_READ_ONLY_CACHE)
  public static let readWriteCache = Self(CL_READ_WRITE_CACHE)
}

public enum CLDeviceLocalMemoryType: cl_device_local_mem_type, CLEnum {
  case local = 0x1
  case global = 0x2
}

public struct CLDeviceExecutionCapabilities: CLBitField {
  public let rawValue: cl_device_exec_capabilities
  public init(
    rawValue: cl_device_exec_capabilities
  ) {
    self.rawValue = rawValue
  }

  public static let kernel = Self(CL_EXEC_KERNEL)
  public static let nativeKernel = Self(CL_EXEC_NATIVE_KERNEL)
}

public struct CLCommandQueueProperties: CLBitField {
  public let rawValue: cl_command_queue_properties
  public init(
    rawValue: cl_command_queue_properties
  ) {
    self.rawValue = rawValue
  }

  public static let outOfOrderExecutionModeEnable = Self(
    CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE)
  public static let profilingEnable = Self(CL_QUEUE_PROFILING_ENABLE)
  public static let onDevice = Self(CL_QUEUE_ON_DEVICE)
  public static let onDeviceDefault = Self(CL_QUEUE_ON_DEVICE_DEFAULT)
}

public struct CLDeviceAffinityDomain: CLBitField {
  public let rawValue: cl_device_affinity_domain
  public init(
    rawValue: cl_device_affinity_domain
  ) {
    self.rawValue = rawValue
  }

  public static let numa = Self(CL_DEVICE_AFFINITY_DOMAIN_NUMA)
  public static let l4Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L4_CACHE)
  public static let l3Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L3_CACHE)
  public static let l2Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L2_CACHE)
  public static let l1Cache = Self(CL_DEVICE_AFFINITY_DOMAIN_L1_CACHE)
  public static let nextPartitionable = Self(
    CL_DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE)
}

public struct CLDeviceSVMCapabilities: CLBitField {
  public let rawValue: cl_device_svm_capabilities
  public init(
    rawValue: cl_device_svm_capabilities
  ) {
    self.rawValue = rawValue
  }

  public static let coarseGrainBuffer = Self(CL_DEVICE_SVM_COARSE_GRAIN_BUFFER)
  public static let fineGrainBuffer = Self(CL_DEVICE_SVM_FINE_GRAIN_BUFFER)
  public static let fineGrainSystem = Self(CL_DEVICE_SVM_FINE_GRAIN_SYSTEM)
  public static let atomics = Self(CL_DEVICE_SVM_ATOMICS)
}

public struct CLMemoryFlags: CLBitField {
  public let rawValue: cl_mem_flags
  public init(
    rawValue: cl_mem_flags
  ) {
    self.rawValue = rawValue
  }

  public static let readWrite = Self(CL_MEM_READ_WRITE)
  public static let writeOnly = Self(CL_MEM_WRITE_ONLY)
  public static let readOnly = Self(CL_MEM_READ_ONLY)
  public static let useHostPointer = Self(CL_MEM_USE_HOST_PTR)
  public static let allocateHostPointer = Self(CL_MEM_ALLOC_HOST_PTR)
  public static let copyHostPointer = Self(CL_MEM_COPY_HOST_PTR)
  public static let hostWriteOnly = Self(CL_MEM_HOST_WRITE_ONLY)
  public static let hostReadOnly = Self(CL_MEM_HOST_READ_ONLY)
  public static let hostNoAccess = Self(CL_MEM_HOST_NO_ACCESS)
  public static let kernelReadAndWrite = Self(CL_MEM_KERNEL_READ_AND_WRITE)
}

// Not all `cl_mem_flags` from "cl.h" are SVM memory flags. Only flags described
// in the OpenCL 3.0 specification under `clSVMAlloc` are.
public struct CLSVMMemoryFlags: CLBitField {
  public let rawValue: cl_svm_mem_flags
  public init(
    rawValue: cl_svm_mem_flags
  ) {
    self.rawValue = rawValue
  }

  public static let readWrite = Self(CL_MEM_READ_WRITE)
  public static let writeOnly = Self(CL_MEM_WRITE_ONLY)
  public static let readOnly = Self(CL_MEM_READ_ONLY)
  public static let fineGrainBuffer = Self(CL_MEM_SVM_FINE_GRAIN_BUFFER)
  public static let atomics = Self(CL_MEM_SVM_ATOMICS)
}

public struct CLMemoryMigrationFlags: CLBitField {
  public let rawValue: cl_mem_migration_flags
  public init(
    rawValue: cl_mem_migration_flags
  ) {
    self.rawValue = rawValue
  }

  public static let host = Self(CL_MIGRATE_MEM_OBJECT_HOST)
  public static let contentUndefined = Self(
    CL_MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED)
}

public enum CLChannelOrder: cl_channel_order, CLEnum {
  case r = 0x10B0
  case a = 0x10B1
  case rg = 0x10B2
  case ra = 0x10B3
  case rgb = 0x10B4
  case rgba = 0x10B5
  case bgra = 0x10B6
  case argb = 0x10B7
  case intensity = 0x10B8
  case luminance = 0x10B9
  case rx = 0x10BA
  case rgx = 0x10BB
  case rgbx = 0x10BC
  case depth = 0x10BD
  case depthStencil = 0x10BE

  // Making all characters lowercase. This looks like it violates the naming
  // convention used elsewhere, but it doesn't. `sRGB` is one word, similar to
  // how `ReLU` and `OpenCL` are all one word. It looks wierd to put `reLU` and
  // `openCL`, so it's better to make them `relu` and `opencl`. Regarding
  // "OpenCL C", other parts of this API translate it to `openclC`. This clearly
  // shows "opencl" came from one word and "C" came from another. The
  // alternative, `openCLC`, looks like something called "CLC" was very open.
  //
  // Even worse, when translating "DirectX 12" to Swift, you could do
  // `directX12` instead of the lowercase `directx12`. Emphasis on the surprise
  // "X!". Imagine the fun Microsoft would have with that in an irreversible,
  // backwards-compatible API. Meanwhile, "Metal 3" becomes the beautiful
  // `metal3` no matter what we do. This favoring of Apple's graphics libraries
  // would sabotage our already finite efforts to make Swift something taken
  // seriously on Windows.
  case srgb = 0x10BF
  case srgbx = 0x10C0
  case srgba = 0x10C1
  case sbgra = 0x10C2
  case abgr = 0x10C3
}

public enum CLChannelType: cl_channel_type, CLEnum {
  case snormInt8 = 0x10D0
  case snormInt16 = 0x10D1
  case unormInt8 = 0x10D2
  case unormInt16 = 0x10D3
  case unormShort565 = 0x10D4
  case unormShort555 = 0x10D5
  case unormInt101010 = 0x10D6
  case signedInt8 = 0x10D7
  case signedInt16 = 0x10D8
  case signedInt32 = 0x10D9
  case unsignedInt8 = 0x10DA
  case unsignedInt16 = 0x10DB
  case unsignedInt32 = 0x10DC
  case halfFloat = 0x10DD
  case float = 0x10DE
  case unormInt24 = 0x10DF
  case unormInt1010102 = 0x10E0
}

public enum CLMemoryObjectType: cl_mem_object_type, CLEnum {
  case buffer = 0x10F0
  case image2D = 0x10F1
  case image3D = 0x10F2
  case image2DArray = 0x10F3
  case image1D = 0x10F4
  case image1DArray = 0x10F5
  case image1DBuffer = 0x10F6
  case pipe = 0x10F7

  @inlinable
  public var isImage: Bool {
    switch self {
    case .buffer,
      .pipe:
      return false
    default:
      return true
    }
  }
}

public enum CLAddressingMode: cl_addressing_mode, CLEnum {
  case none = 0x1130
  case clampToEdge = 0x1131
  case clamp = 0x1132
  case `repeat` = 0x1133
  case mirroredRepeat = 0x1134
}

public enum CLFilterMode: cl_filter_mode, CLEnum {
  case nearest = 0x1140
  case linear = 0x1141
}

public struct CLMapFlags: CLBitField {
  public let rawValue: cl_map_flags
  public init(
    rawValue: cl_map_flags
  ) {
    self.rawValue = rawValue
  }

  public static let read = Self(CL_MAP_READ)
  public static let write = Self(CL_MAP_WRITE)
  public static let writeInvalidateRegion = Self(CL_MAP_WRITE_INVALIDATE_REGION)
}

public enum CLProgramBinaryType: cl_program_binary_type, CLEnum {
  case none = 0x0
  case compiledObject = 0x1
  case library = 0x2
  case executable = 0x4
}

public enum CLBuildStatus: cl_build_status, CLEnum {
  case success = 0
  case none = -1
  case error = -2
  case inProgress = -3
}

public enum CLKernelArgumentAddressQualifier:
  cl_kernel_arg_address_qualifier, CLEnum
{
  case global = 0x119B
  case local = 0x119C
  case constant = 0x119D
  case `private` = 0x119E
}

public enum CLKernelArgumentAccessQualifier:
  cl_kernel_arg_access_qualifier, CLEnum
{
  case readOnly = 0x11A0
  case writeOnly = 0x11A1
  case readWrite = 0x11A2
  case none = 0x11A3
}

public struct CLKernelArgumentTypeQualifier: CLBitField {
  public let rawValue: cl_kernel_arg_type_qualifier
  public init(
    rawValue: cl_kernel_arg_type_qualifier
  ) {
    self.rawValue = rawValue
  }

  public static let none = Self(CL_KERNEL_ARG_TYPE_NONE)
  public static let const = Self(CL_KERNEL_ARG_TYPE_CONST)
  public static let restrict = Self(CL_KERNEL_ARG_TYPE_RESTRICT)
  public static let volatile = Self(CL_KERNEL_ARG_TYPE_VOLATILE)
  public static let pipe = Self(CL_KERNEL_ARG_TYPE_PIPE)
}

public enum CLCommandType: cl_command_type, CLEnum {
  // Choosing `ndrange` instead of `ndRange` because it's one word, just like
  // "NDArray". Apple does something similar with
  // `MPSGraphTensorData.mpsndarray()`.
  case ndrangeKernel = 0x11F0
  case task = 0x11F1
  case nativeKernel = 0x11F2
  case readBuffer = 0x11F3
  case writeBuffer = 0x11F4
  case copyBuffer = 0x11F5
  case readImage = 0x11F6
  case writeImage = 0x11F7
  case copyImage = 0x11F8
  case copyImageToBuffer = 0x11F9
  case copyBufferToImage = 0x11FA
  case mapBuffer = 0x11FB
  case mapImage = 0x11FC
  case unmapMemoryObject = 0x11FD
  case marker = 0x11FE
  case acquireGLObjects = 0x11FF
  case releaseGLObjects = 0x1200
  case readBufferRectangle = 0x1201
  case writeBufferRectangle = 0x1202
  case copyBufferRectangle = 0x1203
  case user = 0x1204
  case barrier = 0x1205
  case migrateMemoryObjects = 0x1206
  case fillBuffer = 0x1207
  case fillImage = 0x1208

  // Not expanding `memfill` to `memoryFill` because then I must expand
  // `memcpy` to `memoryCopy`. "memcpy" is a widely known C function, along with
  // "free". I think the SVM is trying to emulate basic C memory manipulation
  // here.
  case svmFree = 0x1209
  case svmMemcpy = 0x120A
  case svmMemfill = 0x120B
  case svmMap = 0x120C
  case svmUnmap = 0x120D
  case svmMigrateMemory = 0x120E
}

// No associated C typedef or enumeration in COpenCL. SwiftOpenCL synthesizes
// this new type for developer ergonomics. Should this declaration be `public`
// or `internal`?
public enum CLCommandExecutionStatus: Int32, CLEnum {
  case complete = 0x0
  case running = 0x1
  case submitted = 0x2
  case queued = 0x3
}

public enum CLBufferCreateType: cl_buffer_create_type, CLEnum {
  case region = 0x1220
}

public struct CLDeviceAtomicCapabilities: CLBitField {
  public let rawValue: cl_device_atomic_capabilities
  public init(
    rawValue: cl_device_atomic_capabilities
  ) {
    self.rawValue = rawValue
  }

  // Renaming atomic memory orderings to match their description in the OpenCL
  // 3.0 specification.
  public static let relaxed = Self(CL_DEVICE_ATOMIC_ORDER_RELAXED)
  public static let acquireRelease = Self(CL_DEVICE_ATOMIC_ORDER_ACQ_REL)
  public static let sequentiallyConsistent = Self(
    CL_DEVICE_ATOMIC_ORDER_SEQ_CST)
  public static let scopeWorkItem = Self(CL_DEVICE_ATOMIC_SCOPE_WORK_ITEM)
  public static let scopeWorkGroup = Self(CL_DEVICE_ATOMIC_SCOPE_WORK_GROUP)
  public static let device = Self(CL_DEVICE_ATOMIC_SCOPE_DEVICE)
  public static let allDevices = Self(CL_DEVICE_ATOMIC_SCOPE_ALL_DEVICES)
}

// Having the word "Device" twice appears wierd, but it's not a typo. It means
// "device-side enqueue capabilities of a device". There are several other
// "capabilities of a device", such as the atomic capabilities defined above.
public struct CLDeviceDeviceEnqueueCapabilities: CLBitField {
  public let rawValue: cl_device_device_enqueue_capabilities
  public init(
    rawValue: cl_device_device_enqueue_capabilities
  ) {
    self.rawValue = rawValue
  }

  public static let supported = Self(CL_DEVICE_QUEUE_SUPPORTED)
  public static let replaceableDefault = Self(
    CL_DEVICE_QUEUE_REPLACEABLE_DEFAULT)
}
