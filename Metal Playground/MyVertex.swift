//
//  MyVertex.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-10.
//


import SwiftUI
import simd
import MetalKit

struct MyVertex {
    let time: Float
    let position: SIMD3<Float>
    
    static func vertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        
        // notice that we directly subscript attributes rather than
        // initialize the list ourselves. this is because
        // metal defines a fixed max length of these arrays
        // and initializes them for us. so we modify them in place
        if let timeD = descriptor.attributes[0] {
            timeD.format = .float
            // the backslash is swift's "key path literal" syntax
            timeD.offset = MemoryLayout.offset(of: \MyVertex.time)!
            // notice that we have an option to interleave
            // attributes _across buffers_ (but why?)
            timeD.bufferIndex = 0
        }
        
        if let posD = descriptor.attributes[1] {
            posD.format = .float3
            posD.offset = MemoryLayout.offset(of: \MyVertex.position)!
            posD.bufferIndex = 0
        }
        
        if let buf0Layout = descriptor.layouts[0] {
            buf0Layout.stepFunction = .perVertex
            buf0Layout.stride = MemoryLayout<MyVertex>.stride
            // meaningless since stepFunction is pervertex,
            // but set it anyway for explicitness
            buf0Layout.stepRate = 1
        }
        
        return descriptor
    }
}
