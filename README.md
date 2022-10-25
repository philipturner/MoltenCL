# MoltenCL

> This is not a completed library; check the `develop` branch for the latest updates.

The missing OpenCL 3.0 driver for macOS (or iOS). This un-deprecates OpenCL, making Apple devices viable for high-performance GPGPU through an industry-standard API. It uses Metal behind the scenes to minimize CPU overhead and maximize GPU performance.

Features (not exhaustive):
- half precision
- double precision (through emulation on Apple GPUs, possibly hardware FP64 on AMD)
- does not flush the `cl_queue` after every command (which Apple's OpenCL 1.2 driver does)
- compiling shaders in OpenCL C and Metal Shading Language
- transforming OpenCL SPIR-V and AIR binary code into kernel objects
- hardware-accelerated matrix multiplication intrinsics for AI/ML (`simdgroup_matrix`)
- unified shared memory pointers that expose GPU virtual addresses
- built-in integration with hipSYCL
- access to the Metal runtime objects that back OpenCL API types
- Swift bindings for integration into iOS apps

Operating system support:
- iOS/tvOS 16+ (may need to compile shaders ahead-of-time for optimal performance)
- macOS 13+
- requires at least `MTL::GPUFamily::Apple7` or `MTL::GPUFamily::Mac2`
- to fully optimize AIR binaries compiled from OpenCL C/SPIR-V, you must install Metal command-line tools (optional)

## Attribution and Licensing

MoltenCL is available for free under the MIT license. MoltenCL is not owned or endorsed by Apple or the Khronos Group. However, OpenCL is a trademark of Apple.

Uses [philipturner/metal-float64](https://github.com/philipturner/metal-float64) to emulate double-precision arithmetic.

Homebrew came up with the catch phrase "The missing package manager for macOS (or Linux)". I used that phrase for ideas when coming up with a subtitle for this repository.
