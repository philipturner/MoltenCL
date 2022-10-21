# MoltenCL
The missing OpenCL 3.0 driver for macOS

Supported features:
- half precision
- double precision (though emulation, runs fastest on Apple-designed GPUs)
- compiling shaders from MSL, OpenCL C, or the OpenCL SPIR-V dialect
- access to hardware-accelerated matrix multiplication intrinsics
- unified shared memory pointers that expose GPU virtual addresses
- built-in integration for SYCL frontends
