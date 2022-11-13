> Work on this library has been suspended indefinitely. The more future-ready choice is to directly integrate Metal into hipSYCL. That way, SYCL can support more vendors and become more viable to replace CUDA for GPGPU.

# MoltenCL

> This is not a completed library; check the `develop` branch for the latest updates.

The missing OpenCL 3.0 driver for macOS. This un-deprecates OpenCL, making Apple devices viable for high-performance GPGPU through an industry-standard API. It uses Metal behind the scenes to minimize CPU overhead and maximize GPU performance.

Supported features (not exhaustive):
- half precision
- double precision (through emulation)
- waiting to flush the `cl_queue` until multiple commands have queued up
- compiling shaders in OpenCL C and Metal Shading Language
- transforming OpenCL SPIR-V and AIR binary code into kernel objects
- hardware-accelerated matrix multiplication intrinsics for AI/ML (`simdgroup_matrix`)
- SYCL USM device pointers that expose GPU virtual addresses
- subgroup permute/reductions
- workgroup collective functions, async workgroup copies
- built-in integration with hipSYCL
- access to the Metal runtime objects that back OpenCL API types
- Swift bindings for integration into iOS apps

Does not currently support, because of effort required to implement:
- device-side enqueue (requires emulating a lot of features)
- generic address space (needs compiler transformations)
- pipes (requires generic address space)
- program scope global variables (not anticipating significant need for this feature)
- any OpenCL API that is deprecated

Cannot support:
- Shared Virtual Memory (emulating this would seriously degrade performance; instead, access device-only pointers through SYCL)
- OpenCL 2.0 memory consistency model (atomic memory orders besides relaxed, not supported by Apple hardware)

Operating systems:
- iOS/tvOS 16+ (may need to compile shaders ahead-of-time for optimal performance)
- macOS 13+
- requires at least `MTL::GPUFamily::Apple7` or `MTL::GPUFamily::Mac2`
- to fully optimize AIR binaries compiled from OpenCL C/SPIR-V, you must install Metal command-line tools (optional)

## Naming Conventions

The Swift bindings rename the following words in OpenCL macros. Any other deviations from the C API are documented and justified.
- "Addr" to "Address"
- "Alloc" to "Allocation"
- "Arg" to "Argument"
- "Bitfield" to "BitField"
- "Cacheline" to "CacheLine"
- "Ctor" to "Constructor"
- "Config" to "Configuration"
- "Dtor" to "Destructor"
- "Exec" to "Execution"
- "FP" to "FloatingPoint"
- "Mem" to "Memory"
- "Memobject" to "MemoryObject"
- "Ptr" to "Pointer"
- "Rect" to "Rectangle"
- "Spec" to "SpecializationConstant"
- Rephrases each boolean property as a verb, but documents the name change.

## Attribution and Licensing

MoltenCL is available for free under the MIT license. MoltenCL is not owned or endorsed by Apple or the Khronos Group. However, OpenCL is a trademark of Apple.

Uses [philipturner/metal-float64](https://github.com/philipturner/metal-float64) to emulate double-precision arithmetic.

Recycles [philipturner/swift-opencl](https://github.com/philipturner/swift-opencl), an incomplete attempt to wrap OpenCL in Swift bindings.

Homebrew came up with the catch phrase "The missing package manager for macOS (or Linux)". I used that phrase for ideas when coming up with a subtitle for this repository.
