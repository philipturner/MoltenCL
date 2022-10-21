# MoltenCL

The missing OpenCL 3.0 driver for macOS (or iOS). This un-deprecates OpenCL, making Apple devices viable for high-performance GPGPU through an industry-standard API. It uses Metal behind the scenes to minimize CPU overhead and maximize GPU performance.

Features (not exhaustive):
- half precision
- double precision (though emulation; runs fastest on Apple-designed GPUs with native 64-bit integer math)
- does not flush the `cl_queue` after every command (which Apple's OpenCL driver does)
- compiling shaders OpenCL C and Metal Shading Language
- transforming OpenCL SPIR-V and AIR binary code into kernel objects
- hardware-accelerated matrix multiplication intrinsics for ML/AI (`simdgroup_matrix`)
- unified shared memory pointers that expose GPU virtual addresses
- built-in integration with SYCL frontends
- zero-overhead access to the Metal runtime objects that back OpenCL API types (through C, C++, and Swift)
- first-class Swift bindings for integration into iOS apps

Operating system support:
- iOS/tvOS 16+ (may need to compile shaders ahead-of-time for optimal performance)
- macOS 13+
- requires at least `MTL::GPUFamily::Apple6` or `MTL::GPUFamily::Mac2` - anything that can run Metal 3
- to fully optimize AIR binaries compiled from OpenCL C/SPIR-V, you must install Metal command-line tools (optional)

## Attribution and Licensing

MoltenCL is available for free under the MIT license. MoltenCL is not owned or endorsed by Apple or the Khronos Group. However, OpenCL is a trademark of Apple.

Uses [philipturner/metal-float64](https://github.com/philipturner/metal-float64) to emulate double-precision arithmetic.

Homebrew came up with the catch phrase "The missing package manager for macOS (or Linux)". I used that phrase for ideas when coming up with a subtitle for this repository.
