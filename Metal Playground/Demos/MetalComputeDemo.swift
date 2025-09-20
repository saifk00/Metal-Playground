//
//  MetalComputeDemo.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-08.
//

import Metal

struct MetalComputeDemo {
    let result: [Int64]
    init() {
        let device = MTLCreateSystemDefaultDevice()!
        let queue = device.makeCommandQueue()!
        let buf = queue.makeCommandBuffer()!
        let encoder = buf.makeComputeCommandEncoder()!
        
        let A = [1, 2, 3, 4, 5, 6, 0, 0, 0]
        
        let bufLength = A.count * MemoryLayout<Int64>.stride
        let subLength = 3 * MemoryLayout<Int64>.stride
        
        let arrayBuf = device.makeBuffer(bytes: A, length: bufLength)

        encoder.setBuffer(arrayBuf, offset: 0, index: 0)
        encoder.setBuffer(arrayBuf, offset: subLength, index: 1)
        encoder.setBuffer(arrayBuf, offset: 2*subLength, index: 2)
        
        let library = device.makeDefaultLibrary()!
        let addArraysFunc = library.makeFunction(name: "add_arrays")!

        var pipeline: MTLComputePipelineState
        do {
            pipeline = try device.makeComputePipelineState(function: addArraysFunc)
        } catch {
            print("pipeline creation failed")
            self.result = []
            return
        }
        
        encoder.setComputePipelineState(pipeline)
        
        let gridShape = MTLSize(width: 1, height: 1, depth: 1)
        let groupShape = MTLSize(width: A.count, height: 1, depth: 1)
        encoder.dispatchThreadgroups(gridShape, threadsPerThreadgroup: groupShape)
        
        encoder.endEncoding()
        buf.commit()
        buf.waitUntilCompleted()
        
        let outPtr = arrayBuf?.contents().bindMemory(to: Int64.self, capacity: A.count)
        let startPtr = outPtr! + 6
        let bufPtr = UnsafeBufferPointer(start: startPtr, count: 3)
        self.result = Array(bufPtr)
    }
}
