//
//  MetalSceneRenderer.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Metal
import simd

class MetalSceneRenderer {
    private var device: MTLDevice?
    private var pipelineStates: [DrawablePipelineDescriptor: MTLRenderPipelineState] = [:]

    func initPipeline(from scene: CompiledScene, device: MTLDevice) throws {
        self.device = device

        // Create pipeline states for each unique descriptor in the scene
        for renderGroup in scene.renderGroups {
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
        for i in 0..<scene.renderGroups.count {
            var renderGroup = scene.renderGroups[i]

            // Generate vertices for all nodes in this group
            let allVertices = generateVertices(for: renderGroup.nodes)

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
                    for: renderGroup.nodes,
                    vertices: allVertices
                )
            }

            scene.renderGroups[i] = renderGroup
        }
    }

    func draw(scene: CompiledScene, with encoder: MTLRenderCommandEncoder) {
        for renderGroup in scene.renderGroups {
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

    private func createPipelineState(
        for descriptor: DrawablePipelineDescriptor,
        device: MTLDevice
    ) throws -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            throw MetalSceneRendererError.libraryCreationFailed
        }

        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: descriptor.vertexFunction)
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: descriptor.fragmentFunction)
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    }

    private func generateVertices(for nodes: [any AbstractDrawableNode]) -> [PlotDSLVertex] {
        // Stage 1: Generate and store base vertices using visitor pattern
        let vertexGenerator = VertexGeneratorVisitor()
        vertexGenerator.generateVerticesFor(nodes)

        // Stage 2: Apply world transforms to stored vertices using visitor pattern
        let transformApplier = TransformApplierVisitor()
        transformApplier.applyTransformsTo(nodes)

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
                    commands.append(DrawCommand(
                        primitiveType: .triangle,
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
}