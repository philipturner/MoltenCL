import XCTest
import Metal

final class ClockCycleTests: XCTestCase {
    func testThroughput() throws {
        // Calibrated for M1 Max
        let device = MTLCreateSystemDefaultDevice()!
        let library = try! device.makeDefaultLibrary(bundle: Bundle.module)
        let function = library.makeFunction(name: "testALU")!
        let pipeline = try! device.makeComputePipelineState(function: function)
        
        let numThreads = 1_000_000
        let bufferSize = numThreads * MemoryLayout<UInt64>.stride
        let buffer = device.makeBuffer(length: bufferSize, options: .storageModeShared)!
        
        let commandQueue = device.makeCommandQueue()!
        for _ in 0..<10 {
            memset(buffer.contents(), 0, bufferSize)
            
            let cmdbuf = commandQueue.makeCommandBuffer()!
            let encoder = cmdbuf.makeComputeCommandEncoder()!
            encoder.setComputePipelineState(pipeline)
            encoder.setBuffer(buffer, offset: 0, index: 0)
            encoder.dispatchThreads(MTLSizeMake(numThreads,1,1), threadsPerThreadgroup: MTLSizeMake(1,1,1))
            encoder.endEncoding()
            cmdbuf.commit()
            cmdbuf.waitUntilCompleted()
            
            print(Int((cmdbuf.gpuEndTime - cmdbuf.gpuStartTime) * 1e6))
        }
    }
}
