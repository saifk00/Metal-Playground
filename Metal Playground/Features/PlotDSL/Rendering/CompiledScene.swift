//
//  CompiledScene.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Metal
import Foundation

struct CompiledScene {
    let rootNode: any AbstractDrawableNode
    var renderGroups: [UUID: RenderGroup] = [:]
}

struct RenderGroup {
    let groupID: UUID
    let pipelineDescriptor: DrawablePipelineDescriptor

    // CPU-generated data (set during compilation)
    var vertices: [PlotDSLVertex]?
    var drawCommands: [DrawCommand]?

    // GPU resources (set during buffer initialization)
    var vertexBuffer: MTLBuffer?

    init(groupID: UUID, pipelineDescriptor: DrawablePipelineDescriptor) {
        self.groupID = groupID
        self.pipelineDescriptor = pipelineDescriptor
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
