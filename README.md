# MoltenCL

The missing OpenCL 3.0 driver for macOS. This un-deprecates OpenCL, making Apple devices usable for high-performance computing through an industry-standard API.

Supported features (not an exhaustive list):
- half precision
- double precision (though emulation; runs fastest on Apple-designed GPUs)
- does not flush the `cl_queue` after every command (which Apple's OpenCL driver likely does)
- compiling shaders from MSL and OpenCL C source languages
- transforming OpenCL SPIR-V and AIR binary code into kernel objects
- access to hardware-accelerated matrix multiplication intrinsics
- unified shared memory pointers that expose GPU virtual addresses
- built-in integration with SYCL frontends

Operating system support:
- iOS/tvOS 16+ (may need to compile shaders ahead-of-time for optimal performance)
- macOS 13+
- requires at least `MTLGPUFamily.apple6` or `MTLGPUFamily.mac2` - anything that can run Metal 3
- to optimize AIR binaries compiled from OpenCL source, you must have Metal command-line tools installed (optional)

## Licensing

MoltenCL is available for free under the MIT license. MoltenCL is not owned or endorsed by Apple or the Khronos Group. However, OpenCL is a trademark of Apple.
