//
//  ProgressiveProtocols.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd
import Metal

// Stage-specific storage protocols
protocol TransformStorage {
    var worldTransform: simd_float4x4? { get set }
}

protocol PipelineStorage {
    var pipelineDescriptor: DrawablePipelineDescriptor? { get set }
}

protocol BufferStorage {
    var vertexRange: (offset: Int, count: Int)? { get set }
    var gpuBuffer: MTLBuffer? { get set }
}

// Progressive node protocols that combine base + storage
protocol TransformedDrawableNode: AbstractDrawableNode, TransformStorage {}
protocol PipelinedDrawableNode: TransformedDrawableNode, PipelineStorage {}
protocol BufferedDrawableNode: PipelinedDrawableNode, BufferStorage {}

// DrawablePipelineDescriptor is defined in DrawablePipelineDescriptor.swift