# MoltenCL

The missing OpenCL 3.0 driver for macOS

Supported features:
- half precision
- double precision (though emulation; runs fastest on Apple-designed GPUs)
- compiling shaders from MSL and OpenCL C source languages
- transforming OpenCL SPIR-V and AIR binary code into kernel objects
- access to hardware-accelerated matrix multiplication intrinsics
- unified shared memory pointers that expose GPU virtual addresses
- built-in integration for SYCL frontends

Operating system support:
- iOS 16+ (may need to compile shaders ahead-of-time for optimal performance)
- macOS 13+
- requires at least `MTLGPUFamily.apple6` or `MTLGPUFamily.mac2` - anything that can run Metal 3
