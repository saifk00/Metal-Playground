//
//  PlotDSLVertex.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd
import MetalKit

struct PlotDSLVertex : CustomVertexStruct {
    let position : SIMD3<Float>
    let color : SIMD4<Float>
    
    init(_ position: SIMD3<Float>, color: SIMD4<Float> = SIMD4<Float>(1, 1, 1, 1)) {
        self.position = position
        self.color = color
    }
    
    static func vertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        
        if let pos = descriptor.attributes[0] {
            pos.format = .float3
            pos.offset = 0
            pos.bufferIndex = 0
        }
        
        if let color = descriptor.attributes[1] {
            color.format = .float4
            color.offset = MemoryLayout<SIMD3<Float>>.size
            color.bufferIndex = 0
        }
        
        if let layout = descriptor.layouts[0] {
            layout.stepFunction = .perVertex
            layout.stride = MemoryLayout<PlotDSLVertex>.stride
            layout.stepRate = 1
        }
        
        return descriptor
    }
}