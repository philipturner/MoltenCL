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

  // Named `_vendor` to avoid name collision with public `vendor`.
  var _vendor: CLVendor

  public init(
    mtlDevice: MTLDevice
  ) {
    self.mtlDevice = mtlDevice
    self.referenceCount = 0
    self._vendor = CLVendor(mtlDevice: mtlDevice)
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
        switch CLVendor(mtlDevice: device) {
        case .apple, .amd:
          bestCandidate = device
        case .intel:
          if bestCandidate == nil {
            bestCandidate = device
          }
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
    notImplementedError()
  }

  public var maxWorkItemDimensions: UInt32 {
    3
  }

  public var maxWorkItemSizes: [Int] {
    let size = mtlDevice.maxThreadsPerThreadgroup
    return [size.width, size.height, size.depth]
  }

  public var maxWorkGroupSize: Int {
    let size = mtlDevice.maxThreadsPerThreadgroup
    return max(size.width, size.height, size.depth)
  }

  public var preferredVectorWidthChar: UInt32 {
    switch _vendor {
    case .amd: return 4
    default: return 1
    }
  }

  public var preferredVectorWidthShort: UInt32 {
    switch _vendor {
    case .amd: return 2
    default: return 1
    }
  }

  public var preferredVectorWidthInt: UInt32 {
    1
  }

  public var preferredVectorWidthLong: UInt32 {
    1
  }

  public var preferredVectorWidthFloat: UInt32 {
    1
  }

  public var preferredVectorWidthDouble: UInt32 {
    // Encourage coalescing 4 operations into one function call.
    4
  }

  public var preferredVectorWidthHalf: UInt32 {
    // AMD GPU has vector width 1, unlike with 16-bit integers:
    // https://bbs.archlinux.org/viewtopic.php?id=264347
    1
  }

  public var nativeVectorWidthChar: UInt32 {
    switch _vendor {
    case .amd: return 4
    default: return 1
    }
  }

  public var nativeVectorWidthShort: UInt32 {
    switch _vendor {
    case .amd: return 2
    default: return 1
    }
  }

  public var nativeVectorWidthInt: UInt32 {
    1
  }

  public var nativeVectorWidthLong: UInt32 {
    1
  }

  public var nativeVectorWidthFloat: UInt32 {
    1
  }

  public var nativeVectorWidthDouble: UInt32 {
    // Encourage coalescing 4 operations into one function call.
    4
  }

  public var nativeVectorWidthHalf: UInt32 {
    // AMD GPU has vector width 1, unlike with 16-bit integers:
    // https://bbs.archlinux.org/viewtopic.php?id=264347
    1
  }

  public var maxClockFrequency: UInt32 {
    // TODO: For Intel Macs, call into Apple's OpenCL driver through an external
    // process. On Apple silicon, use `powermetrics` to find the maximum speed.

    // TODO: On iOS, use DeviceKit to find the model. Using Wikipedia and manual
    // measurements, get a high-quality estimate of the clock speed. We don't
    // know whether Apple throttles clock speed for 4-core A15 chips.
    notImplementedError()
  }

  public var addressBits: UInt32 {
    // Don't know whether larger AMD GPUs (e.g. 5600M) use 64 bits on Mac OpenCL
    // driver. Based on `clinfo` results attached, it switched the 64 bits on
    // Linux.
    // https://bbs.archlinux.org/viewtopic.php?id=269794

    // TODO: Get someone with a larger AMD GPU to validate this.
    switch _vendor {
    case .amd:
      if mtlDevice.recommendedMaxWorkingSetSize > 4 * 1024 * 1024 * 1024 {
        return 64
      } else {
        return 32
      }
    default:
      return 64
    }
  }

  public var maxMemoryAllocationSize: UInt64 {
    UInt64(mtlDevice.maxBufferLength)
  }

  // Rephrases "imageSupport" to "supportsImages".
  public var supportsImages: Bool {
    true
  }

  public var maxReadImageArguments: UInt32 {
    128
  }

  public var maxWriteImageArguments: UInt32 {
    128
  }

  public var maxReadWriteImageArguments: UInt32 {
    128
  }

  // Use MSL version as the AIR version. Each MSL version adds language features
  // incompatible with the previous OS's AIR compiler.
  public var ilVersions: [String] {
    ["SPIR-V_1.6", "AIR_3.0"]
  }

  public var ilsWithVersion: [CLNameVersion] {
    [
      CLNameVersion(version: .init(major: 1, minor: 6), name: "SPIR-V"),
      CLNameVersion(version: .init(major: 3, minor: 0), name: "AIR"),
    ]
  }

  public var image2DMaxWidth: Int {
    16384
  }

  public var image2DMaxHeight: Int {
    16384
  }

  public var image3DMaxWidth: Int {
    16384
  }

  public var image3DMaxHeight: Int {
    16384
  }

  public var image3DMaxDepth: Int {
    16384
  }

  // Maximum width of a `texture_buffer`, not width of a `texture1d`. OpenCL C
  // has a special type for this, `image1d_buffer_t`.
  public var imageMaxBufferSize: Int {
    // In all tested devices, there was a constant value across vendors.
    switch _vendor {
    case .apple:
      // Tested A14 (from recollection)
      // Tested M1 Max
      // Tested A15
      return 256 * 1024 * 1024
    case .intel:
      // Tested HD Graphics 630
      // Tested UHD Graphics 630
      // Tested Iris Pro
      return 24 * 1024 * 1024
    case .amd:
      // Tested Radeon R9 M370X
      // Tested Radeon Pro 560
      return 64 * 1024
    }
  }

  public var imageMaxArraySize: Int {
    2048
  }

  public var maxSamplers: UInt32 {
    16
  }

  public var imagePitchAlignment: UInt32 {
    // Specification implies this value would vary, depending on the pixel type.
    // However, there is no place to specify the pixel type when querying this
    // property! The link below suggests it's the minimum row width, in bytes:
    // https://github.com/KhronosGroup/OpenCL-Docs/issues/674
    UInt32(mtlDevice.minimumLinearTextureAlignment(for: .r8Uint))
  }

  public var imageBaseAddressAlignment: UInt32 {
    // According to the Metal API docs, `minimumLinearTextureAlignment` serves
    // as alignment for both `offset` and `bytesPerRow`.
    UInt32(mtlDevice.minimumLinearTextureAlignment(for: .r8Uint))
  }

  public var maxPipeArguments: UInt32 {
    16
  }

  public var pipeMaxActiveReservations: UInt32 {
    // AMD allows up to 16 reservations per thread, or 16 * 1024 reservations
    // per threadgroup. Allowing multiple reservations per work item could make
    // scheduling logic more complex, and reduce performance.
    //
    // Intel uses this packet size:
    // https://bugzilla.redhat.com/show_bug.cgi?id=2075944
    1
  }

  public var pipeMaxPacketSize: UInt32 {
    // AMD seems to limit packet size to 1/8 of global memory. However, an
    // emulated `cl_pipe` implementation might run faster with fixed packet
    // size.
    //
    // Intel uses this packet size:
    // https://bugzilla.redhat.com/show_bug.cgi?id=2075944
    1024
  }

  public var maxParameterSize: Int {
    // Maximum size of constant buffer arguments in Metal.
    4096
  }

  public var memoryBaseAddressAlign: Int {
    // Alignment in bits, not bytes.
    switch _vendor {
    case .apple:
      return 4096 * 8
    case .intel:
      return 128 * 8
    case .amd:
      return 4096 * 8
    }
  }

  public var singleFloatingPointConfiguration:
    CLDeviceFloatingPointConfiguration
  {
    return [
      // Denorms are disabled in Apple's OpenCL driver, but available in AIR.
      .denorm,
      .infNaN,
      .roundToNearest,
      .roundToZero,

      // Round to infinity accomplished through emulation.
      .roundToInf,
      .fma,

      // Correctly rounded divide/sqrt specified through a compile option.
      // Precise versions of each MSL function should also be exposed to SPIR-V
      // individually.
      //
      // This feature is exclusive to single precision; no other configurations
      // should include it.
      .correctlyRoundedDivideSqrt,
    ]
  }

  public var doubleFloatingPointConfiguration:
    CLDeviceFloatingPointConfiguration
  {
    return [
      .denorm,
      .infNaN,
      .roundToNearest,
      .roundToZero,
      .roundToInf,
      .fma,

      // Use emulation on all devices, including those with hardware FP64.
      .softFloat,
    ]
  }

  // NOTE: The OpenCL 3.0 specification does not include the macro for this.
  public var halfFloatingPointConfiguration: CLDeviceFloatingPointConfiguration
  {
    return [
      // Denorms are disabled in Apple's OpenCL driver, but available in AIR.
      .denorm,
      .infNaN,
      .roundToNearest,
      .roundToZero,

      // Round to infinity accomplished through emulation.
      .roundToInf,
      .fma,
    ]
  }

  var globalMemoryCacheType: CLDeviceMemoryCacheType {
    .none
  }

  var globalMemoryCacheLineSize: UInt32 {
    0
  }

  var globalMemoryCacheSize: UInt64 {
    0
  }

  var globalMemorySize: UInt64 {
    // Not the actual memory size on Apple silicon; rather, something close to
    // 70% of the total RAM. The maximum usable RAM gets murky, because it's
    // shared with the CPU and can page to the disk.
    mtlDevice.recommendedMaxWorkingSetSize
  }

  var maxConstantBufferSize: UInt64 {
    switch _vendor {
    case .apple:
      return 1024 * 1024 * 1024
    default:
      return 64 * 1024
    }
  }

  var maxConstantArguments: UInt32 {
    switch _vendor {
    case .apple:
      return 31
    default:
      // The MSL specification says 14, but Apple's OpenCL driver says 8.
      return 14
    }
  }

  var maxGlobalVariableSize: Int {
    // Not supporting global variables yet.
    0
  }

  var globalVariablePreferredTotalSize: Int {
    // Not supporting global variables yet.
    0
  }

  var localMemoryType: CLDeviceLocalMemoryType {
    .local
  }

  var localMemorySize: UInt64 {
    UInt64(mtlDevice.maxThreadgroupMemoryLength)
  }

  // Rephrases "errorCorrectionSupport" to "supportsErrorCorrection".
  var supportsErrorCorrection: Bool {
    false
  }

  var profilingTimerResolution: UInt64 {
    // TODO: Use OpenCL to find the exact resolution on Intel and AMD.
    // TODO: Manually test Apple's profiling timer resolution, because I don't
    // trust the extremely low value of 1000 ns acquired from Apple's OpenCL
    // driver. Especially when CPU and GPU are in perfect sync, while CPU has a
    // supposed resolution of 41 ns.
    notImplementedError()
  }

  // Rephrases "endianLittle" to "isLittleEndian".
  public var isLittleEndian: Bool {
    true
  }

  // Rephrases "available" to "isAvailable".
  public var isAvailable: Bool {
    true
  }

  // Rephrases "compilerAvailable" to "compilerIsAvailable".
  public var compilerIsAvailable: Bool {
    // On iOS, the online compiler may not support all optimizations.
    true
  }

  // Rephrases "linkerAvailable" to "linkerIsAvailable".
  public var linkerIsAvailable: Bool {
    true
  }

  public var executionCapabilities: CLDeviceExecutionCapabilities {
    .kernel
  }

  public var queueOnHostProperties: CLCommandQueueProperties {
    // These two profiling methods are mutually exclusive.
    if mtlDevice.supportsCounterSampling(.atDispatchBoundary),
      mtlDevice.supportsCounterSampling(.atBlitBoundary)
    {
      // Can profile without creating a new command encoder.
      // Only possible on Intel Macs.
      return [.outOfOrderExecutionModeEnable, .profilingEnable]
    } else if mtlDevice.supportsCounterSampling(.atStageBoundary) {
      // Must profile by creating a new command encoder.
      // Only possible on Apple silicon Macs and iOS.
      return [.outOfOrderExecutionModeEnable, .profilingEnable]
    } else {
      fatalError("Metal device '\(mtlDevice.name)' does not support profiling.")
    }
  }

  public var queueOnDeviceProperties: CLCommandQueueProperties {
    // MoltenCL does not support on-device queues yet.
    []
  }

  public var queueOnDevicePreferredSize: UInt32 {
    0
  }

  public var queueOnDeviceMaxSize: UInt32 {
    0
  }

  public var maxOnDeviceQueues: UInt32 {
    0
  }

  public var maxOnDeviceEvents: UInt32 {
    0
  }

  public var builtInKernels: [String] {
    []
  }

  public var builtInKernelsWithVersion: [CLNameVersion] {
    []
  }

  public var platform: CLPlatform {
    CLPlatform.default
  }

  public var name: String {
    mtlDevice.name
  }

  public var vendor: String {
    "Apple"
  }

  // The C macro `CL_DRIVER_VERSION` does not include the word "DEVICE".
  public var driverVersion: String {
    // Alpha version, pre-release.
    //
    // TODO: Make GitHub action that automatically writes the version into a
    // Swift source file, as a global variable. Force this action to trigger
    // before each new release.
    "0.1"
  }

  public var profile: String {
    platform.profile
  }

  public var version: String {
    platform.version
  }

  public var numericVersion: CLVersion {
    platform.numericVersion
  }

  public var openclCAllVersions: [CLNameVersion] {
    // Returns newest first to ensure OpenCL C 3.0 is recognized.
    return [
      .init(version: .init(major: 3, minor: 0), name: "OpenCL C"),
      .init(version: .init(major: 1, minor: 2), name: "OpenCL C"),
      .init(version: .init(major: 1, minor: 1), name: "OpenCL C"),
      .init(version: .init(major: 1, minor: 0), name: "OpenCL C"),
    ]
  }

  public var openclCFeatures: [CLNameVersion] {
    let _3_0_0 = CLVersion(major: 1, minor: 1, patch: 0)
    // TODO: Finish this.
    fatalError()
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

  func writeInfo<T: CLInfo>(_ value: T) -> Int32 {
    value.writeInfo(param_value_size, param_value, param_value_size_ret)
  }

  switch Int32(bitPattern: param_name) {
  case CL_DEVICE_TYPE:
    return writeInfo(device.type.rawValue)
  case CL_DEVICE_VENDOR_ID:
    return writeInfo(device.vendorID)
  case CL_DEVICE_MAX_COMPUTE_UNITS:
    return writeInfo(device.maxComputeUnits)
  case CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS:
    return writeInfo(device.maxComputeUnits)
  case CL_DEVICE_MAX_WORK_ITEM_SIZES:
    return writeInfo(device.maxWorkItemSizes)
  case CL_DEVICE_MAX_WORK_GROUP_SIZE:
    return writeInfo(device.maxWorkGroupSize)

  case CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR:
    return writeInfo(device.preferredVectorWidthChar)
  case CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT:
    return writeInfo(device.preferredVectorWidthShort)
  case CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT:
    return writeInfo(device.preferredVectorWidthInt)
  case CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG:
    return writeInfo(device.preferredVectorWidthLong)
  case CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT:
    return writeInfo(device.preferredVectorWidthFloat)
  case CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE:
    return writeInfo(device.preferredVectorWidthDouble)
  case CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF:
    return writeInfo(device.preferredVectorWidthHalf)

  case CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR:
    return writeInfo(device.nativeVectorWidthChar)
  case CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT:
    return writeInfo(device.nativeVectorWidthShort)
  case CL_DEVICE_NATIVE_VECTOR_WIDTH_INT:
    return writeInfo(device.nativeVectorWidthInt)
  case CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG:
    return writeInfo(device.nativeVectorWidthLong)
  case CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT:
    return writeInfo(device.nativeVectorWidthFloat)
  case CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE:
    return writeInfo(device.nativeVectorWidthDouble)
  case CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF:
    return writeInfo(device.nativeVectorWidthHalf)

  case CL_DEVICE_MAX_CLOCK_FREQUENCY:
    return writeInfo(device.maxClockFrequency)
  case CL_DEVICE_ADDRESS_BITS:
    return writeInfo(device.addressBits)
  case CL_DEVICE_MAX_MEM_ALLOC_SIZE:
    return writeInfo(device.maxMemoryAllocationSize)
  case CL_DEVICE_IMAGE_SUPPORT:
    return writeInfo(device.supportsImages)
  case CL_DEVICE_MAX_READ_IMAGE_ARGS:
    return writeInfo(device.maxReadImageArguments)
  case CL_DEVICE_MAX_WRITE_IMAGE_ARGS:
    return writeInfo(device.maxWriteImageArguments)
  case CL_DEVICE_MAX_READ_WRITE_IMAGE_ARGS:
    return writeInfo(device.maxReadWriteImageArguments)
  case CL_DEVICE_IL_VERSION:
    return writeInfo(device.ilVersions)
  case CL_DEVICE_ILS_WITH_VERSION:
    return writeInfo(device.ilsWithVersion)

  case CL_DEVICE_IMAGE2D_MAX_WIDTH:
    return writeInfo(device.image2DMaxWidth)
  case CL_DEVICE_IMAGE2D_MAX_HEIGHT:
    return writeInfo(device.image2DMaxHeight)
  case CL_DEVICE_IMAGE3D_MAX_WIDTH:
    return writeInfo(device.image3DMaxWidth)
  case CL_DEVICE_IMAGE3D_MAX_HEIGHT:
    return writeInfo(device.image3DMaxHeight)
  case CL_DEVICE_IMAGE3D_MAX_DEPTH:
    return writeInfo(device.image3DMaxDepth)
  case CL_DEVICE_IMAGE_MAX_BUFFER_SIZE:
    return writeInfo(device.imageMaxBufferSize)
  case CL_DEVICE_IMAGE_MAX_ARRAY_SIZE:
    return writeInfo(device.imageMaxArraySize)
  case CL_DEVICE_MAX_SAMPLERS:
    return writeInfo(device.maxSamplers)
  case CL_DEVICE_IMAGE_PITCH_ALIGNMENT:
    return writeInfo(device.imagePitchAlignment)
  case CL_DEVICE_IMAGE_BASE_ADDRESS_ALIGNMENT:
    return writeInfo(device.imageBaseAddressAlignment)

  case CL_DEVICE_MAX_PIPE_ARGS:
    return writeInfo(device.maxPipeArguments)
  case CL_DEVICE_PIPE_MAX_ACTIVE_RESERVATIONS:
    return writeInfo(device.pipeMaxActiveReservations)
  case CL_DEVICE_PIPE_MAX_PACKET_SIZE:
    return writeInfo(device.pipeMaxPacketSize)
  case CL_DEVICE_MAX_PARAMETER_SIZE:
    return writeInfo(device.maxParameterSize)
  default:
    return CL_INVALID_VALUE
  }
}
