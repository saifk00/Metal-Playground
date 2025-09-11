//
//  TriangleDemo.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-10.
//


import SwiftUI
import simd
import MetalKit

struct TriangleDemo : DemoRunner {
    let tResolution: Int = 360
    let t0: Double
    var triangleSequenceVertices: MTLBuffer?
    
    init() {
        t0 = Double(CACurrentMediaTime())
    }
    
    func initPipeline(for device: MTLDevice) -> MTLRenderPipelineState {
        let pipeline = MTLRenderPipelineDescriptor()

        // Q: why do you need a device to make a library?
        // A: the shaders need to be compiled _for this device_ to be used
        let library = device.makeDefaultLibrary()!
        
        pipeline.vertexFunction = library.makeFunction(name: "vertex_shader")!
        pipeline.fragmentFunction = library.makeFunction(name: "fragment_shader")!
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipeline.vertexDescriptor = MyVertex.vertexDescriptor()
        
        return try! device.makeRenderPipelineState(descriptor: pipeline)
    }
    
    mutating func initBuffers(for device: MTLDevice) {
        let times = Array(0...tResolution)
        let vertices: [MyVertex] = times.flatMap { t in
            MetalRenderDemo.makeVerticesForTriangle(at: t)
        }

        triangleSequenceVertices = device.makeBuffer(bytes: vertices,
                                             length: MemoryLayout<MyVertex>.stride * vertices.count,
                                             options: [])!
    }
    
    func draw(with encoder: MTLRenderCommandEncoder) {
        let time = Int(floor((CACurrentMediaTime() - self.t0) * 60.0))
        // 1. do the drawing
        let wrappedTime = time % tResolution
        encoder.setVertexBuffer(triangleSequenceVertices, offset: 0, index: 0)
        // we copied the vertex data maxT times, so we can just render the triangles
        // at time*3 to get the right time values
        encoder.drawPrimitives(type: .triangle, vertexStart: wrappedTime * 3, vertexCount: 3)
    }
}
