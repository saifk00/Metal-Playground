//
//  QuadDemo.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-10.
//


import SwiftUI
import simd
import MetalKit

struct QuadDemo : DemoRunner  {
    var flatQuadBuffer: MTLBuffer?
    var flatQuadIdx: MTLBuffer?
    func initPipeline(for device: any MTLDevice) -> any MTLRenderPipelineState {
        let pipeline = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()!
        
        pipeline.vertexFunction = library.makeFunction(name: "quad_vertex_shader")!
        pipeline.fragmentFunction = library.makeFunction(name: "quad_fragment_shader")!
        
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        // TODO theres no reason flatquad needs time - we can omit this
        pipeline.vertexDescriptor = MyVertex.vertexDescriptor()
        
        return try! device.makeRenderPipelineState(descriptor: pipeline)
    }
    
    mutating func initBuffers(for device: any MTLDevice) {
        flatQuadBuffer = device.makeBuffer(bytes: [
            MyVertex(time: 0.0, position: SIMD3<Float>(-1, -1, 0)),
            MyVertex(time: 0.0, position: SIMD3<Float>(-1, 1, 0)),
            MyVertex(time: 0.0, position: SIMD3<Float>(1, 1, 0)),
            MyVertex(time: 0.0, position: SIMD3<Float>(1, -1, 0)),
        ], length: MemoryLayout<MyVertex>.stride * 4,
                                     options: [])!
        
        let indices: [UInt16] = [
            0, 1, 2,
            0, 2, 3
        ]
        
        flatQuadIdx = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.stride * 6,
                                        options: [])!;
    }
    
    func draw(with encoder: any MTLRenderCommandEncoder) {
        print("QuadDemo.draw() called")
        
        guard let vertexBuffer = flatQuadBuffer else {
            print("ERROR: flatQuadBuffer is nil!")
            return
        }
        
        guard let indexBuffer = flatQuadIdx else {
            print("ERROR: flatQuadIdx is nil!")
            return
        }
        
        print("QuadDemo: Setting vertex buffer and drawing")
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.drawIndexedPrimitives(
            type:.triangle,
            indexCount: 6,
            indexType: .uint16,
            indexBuffer: indexBuffer,
            indexBufferOffset: 0)
        print("QuadDemo.draw() completed")
    }
    
    
}
