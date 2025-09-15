//
//  CompiledScene.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Metal

struct CompiledScene {
    var renderGroups: [RenderGroup]
}

struct RenderGroup {
    let pipelineDescriptor: DrawablePipelineDescriptor
    let nodes: [any AbstractDrawableNode]

    // GPU resources (set during buffer initialization)
    var vertexBuffer: MTLBuffer?
    var drawCommands: [DrawCommand]?

    init(pipelineDescriptor: DrawablePipelineDescriptor, nodes: [any AbstractDrawableNode]) {
        self.pipelineDescriptor = pipelineDescriptor
        self.nodes = nodes
    }
}

struct DrawCommand {
    let primitiveType: MTLPrimitiveType
    let vertexStart: Int
    let vertexCount: Int

    init(primitiveType: MTLPrimitiveType = .triangle, vertexStart: Int, vertexCount: Int) {
        self.primitiveType = primitiveType
        self.vertexStart = vertexStart
        self.vertexCount = vertexCount
    }
}