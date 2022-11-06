# MoltenCL

> This is not a completed library; check the `develop` branch for the latest updates.

The missing OpenCL 3.0 driver for macOS. This un-deprecates OpenCL, making Apple devices viable for high-performance GPGPU through an industry-standard API. It uses Metal behind the scenes to minimize CPU overhead and maximize GPU performance.

Features (not exhaustive):
- half precision
- double precision (through emulation on Apple GPUs, possibly hardware FP64 on AMD)
- waiting to flush the `cl_queue` until multiple commands have queued up
- compiling shaders in OpenCL C and Metal Shading Language
- transforming OpenCL SPIR-V and AIR binary code into kernel objects
- hardware-accelerated matrix multiplication intrinsics for AI/ML (`simdgroup_matrix`)
- unified shared memory pointers that expose GPU virtual addresses
- built-in integration with hipSYCL
- access to the Metal runtime objects that back OpenCL API types
- Swift bindings for integration into iOS apps

Does not support:
- Shared Virtual Memory
- Device-side enqueue (this may be possible to emulate, but not supporting for now)
- OpenCL 2.0 memory consistency model (atomic memory orders besides relaxed)
- Generic address space
- Any OpenCL API that is deprecated

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

## Attribution and Licensing

MoltenCL is available for free under the MIT license. MoltenCL is not owned or endorsed by Apple or the Khronos Group. However, OpenCL is a trademark of Apple.

Uses [philipturner/metal-float64](https://github.com/philipturner/metal-float64) to emulate double-precision arithmetic.

Recycles [philipturner/swift-opencl](https://github.com/philipturner/swift-opencl), an incomplete attempt to wrap OpenCL in Swift bindings.

Homebrew came up with the catch phrase "The missing package manager for macOS (or Linux)". I used that phrase for ideas when coming up with a subtitle for this repository.
