//
//  MetalSceneRenderer.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Metal
import simd
import Foundation

class MetalSceneRenderer {
    private var device: MTLDevice?
    private var pipelineStates: [DrawablePipelineDescriptor: MTLRenderPipelineState] = [:]
    private var depthStencilState: MTLDepthStencilState?

    func initPipeline(from scene: CompiledScene, device: MTLDevice) throws {
        self.device = device

        // Create depth stencil state for proper 3D depth testing
        // across _all_ render groups
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .less
        depthDescriptor.isDepthWriteEnabled = true
        self.depthStencilState = device.makeDepthStencilState(descriptor: depthDescriptor)

        // Create pipeline states for each unique descriptor in the scene
        for (_, renderGroup) in scene.renderGroups {
            if pipelineStates[renderGroup.pipelineDescriptor] == nil {
                let pipelineState = try createPipelineState(
                    for: renderGroup.pipelineDescriptor,
                    device: device
                )
                pipelineStates[renderGroup.pipelineDescriptor] = pipelineState
            }
        }
    }

    func initBuffers(from scene: inout CompiledScene) throws {
        guard let device = device else {
            throw MetalSceneRendererError.deviceNotSet
        }

        // Generate vertex buffers and draw commands for each render group
        for (groupID, var renderGroup) in scene.renderGroups {
            // Collect all nodes that belong to this render group
            let nodesInGroup = collectNodesForGroup(groupID, from: scene.rootNode)

            // Generate vertices for all nodes in this group
            let allVertices = generateVertices(for: nodesInGroup)

            // Create GPU buffer
            if !allVertices.isEmpty {
                let bufferSize = allVertices.count * MemoryLayout<PlotDSLVertex>.stride
                renderGroup.vertexBuffer = device.makeBuffer(
                    bytes: allVertices,
                    length: bufferSize,
                    options: []
                )

                // Generate draw commands based on vertex data
                renderGroup.drawCommands = generateDrawCommands(
                    for: nodesInGroup,
                    vertices: allVertices
                )
            }

            scene.renderGroups[groupID] = renderGroup
        }
    }

    func draw(scene: CompiledScene, with encoder: MTLRenderCommandEncoder) {
        // Set depth stencil state once for all render groups to enable depth testing
        if let depthStencilState = self.depthStencilState {
            encoder.setDepthStencilState(depthStencilState)
        }

        for (_, renderGroup) in scene.renderGroups {
            guard let pipelineState = pipelineStates[renderGroup.pipelineDescriptor],
                  let vertexBuffer = renderGroup.vertexBuffer,
                  let drawCommands = renderGroup.drawCommands else {
                continue
            }

            // Set pipeline state and vertex buffer
            encoder.setRenderPipelineState(pipelineState)
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)

            // Execute draw commands
            for command in drawCommands {
                encoder.drawPrimitives(
                    type: command.primitiveType,
                    vertexStart: command.vertexStart,
                    vertexCount: command.vertexCount
                )
            }
        }
    }

    private func collectNodesForGroup(_ groupID: UUID, from rootNode: any AbstractDrawableNode) -> [any AbstractDrawableNode] {
        let allNodes = DrawableCollectorVisitor.collectDrawables(from: rootNode)
        return allNodes.filter { $0.renderGroupID == groupID }
    }

    private func createPipelineState(
        for descriptor: DrawablePipelineDescriptor,
        device: MTLDevice
    ) throws -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            throw MetalSceneRendererError.libraryCreationFailed
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()

        guard let vertexFunction = library.makeFunction(name: descriptor.vertexFunction) else {
            throw MetalSceneRendererError.shaderFunctionNotFound(descriptor.vertexFunction)
        }

        guard let fragmentFunction = library.makeFunction(name: descriptor.fragmentFunction) else {
            throw MetalSceneRendererError.shaderFunctionNotFound(descriptor.fragmentFunction)
        }

        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float

        // Set vertex descriptor for PlotDSLVertex
        pipelineDescriptor.vertexDescriptor = PlotDSLVertex.vertexDescriptor()

        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    private func generateVertices(for nodes: [any AbstractDrawableNode]) -> [PlotDSLVertex] {
        // Stage 1: Generate and store base vertices using visitor pattern
        VertexGeneratorVisitor.generateVertices(for: nodes)

        // Stage 2: Apply world transforms to stored vertices using visitor pattern
        TransformApplierVisitor.applyTransforms(to: nodes)

        // Stage 3: Collect the transformed vertices from all nodes
        var allTransformedVertices: [PlotDSLVertex] = []
        for node in nodes {
            if let vertices = node.getVertices() {
                allTransformedVertices.append(contentsOf: vertices)
            }
        }

        return allTransformedVertices
    }

    private func generateDrawCommands(
        for nodes: [any AbstractDrawableNode],
        vertices: [PlotDSLVertex]
    ) -> [DrawCommand] {
        var commands: [DrawCommand] = []
        var vertexOffset = 0

        for node in nodes {
            if let drawableNode = node as? any DrawableNode {
                let vertexCount = drawableNode.vertexCount()

                if vertexCount > 0 {
                    // Choose primitive type based on node type
                    let primitiveType: MTLPrimitiveType
                    switch node {
                    case is Line2D, is Line3D:
                        primitiveType = .line
                    case is Plane, is PlaneNode:
                        primitiveType = .triangle
                    default:
                        primitiveType = .triangle
                    }

                    commands.append(DrawCommand(
                        primitiveType: primitiveType,
                        vertexStart: vertexOffset,
                        vertexCount: vertexCount
                    ))
                    vertexOffset += vertexCount
                }
            }
        }

        return commands
    }
}

enum MetalSceneRendererError: Error {
    case deviceNotSet
    case libraryCreationFailed
    case shaderFunctionNotFound(String)
}
