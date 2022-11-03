//
//  CLErrorCode.swift
//
//
//  Created by Philip Turner on 10/23/22.
//

import COpenCL

public enum CLErrorCode: Int32, CaseIterable {
  // OpenCL 1.0

  case success = 0
  case deviceNotFound = -1
  case deviceNotAvailable = -2
  case compilerNotAvailable = -3
  case memoryObjectAllocationFailure = -4
  case outOfResources = -5
  case outOfHostMemory = -6
  case profilingInfoNotAvailable = -7
  case memoryCopyOverlap = -8
  case imageFormatMismatch = -9
  case imageFormatNotSupported = -10
  case buildProgramFailure = -11
  case mapFailure = -12

  // OpenCL 1.1

  case misalignedSubBufferOffset = -13
  case executionStatusErrorForEventsInWaitList = -14

  // OpenCL 1.2

  case compileProgramFailure = -15
  case linkerNotAvailable = -16
  case linkPrograrmFailure = -17
  case devicePartitionFailed = -18
  case kernelArgumentInfoNotAvailable = -19

  // Start over at OpenCL 1.0, this time increasing versions indefinitely.

  // OpenCL 1.0

  case invalidValue = -30
  case invalidDeviceType = -31
  case invalidPlatform = -32
  case invalidDevice = -33
  case invalidContext = -34
  case invalidQueueProperties = -35
  case invalidCommandQueue = -36
  case invalidHostPointer = -37
  case invalidMemoryObject = -38
  case invalidImageFormatDescriptor = -39
  case invalidImageSize = -40
  case invalidSampler = -41
  case invalidBinary = -42
  case invalidBuildOptions = -43
  case invalidProgram = -44
  case invalidProgramExecutable = -45
  case invalidKernelName = -46
  case invalidKernelDefinition = -47
  case invalidKernel = -48
  case invalidArgumentIndex = -49
  case invalidArgumentValue = -50
  case invalidArgumentSize = -51
  case invalidKernelArguments = -52
  case invalidWorkDimension = -53
  case invalidWorkGroupSize = -54
  case invalidWorkItemSize = -55
  case invalidGlobalOffset = -56
  case invalidEventWaitList = -57
  case invalidEvent = -58
  case invalidOperation = -59
  case invalidGLObject = -60
  case invalidBufferSize = -61
  case invalidMipLevel = -62
  case invalidGlobalWorkSize = -63

  // OpenCL 1.1

  case invalidProperty = -64

  // OpenCL 1.2

  case invalidImageDescriptor = -65
  case invalidCompilerOptions = -66
  case invalidLinkerOptions = -67
  case invalidDevicePartitionCount = -68

  // OpenCL 2.0

  case invalidPipeSize = -69
  case invalidDeviceQueue = -70

  // OpenCL 2.2

  case invalidSpecializationConstantID = -71
  case maxSizeRestrictionExceeded = -72
}
