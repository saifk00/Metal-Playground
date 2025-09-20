//
//  DrawableCompiler.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd
import Foundation
import Metal

class DrawableCompiler {

    func compile(_ rootNode: any AbstractDrawableNode) -> CompiledScene {
        // Stage 1: Apply transform visitors
        let _ = applyTransformStage(rootNode)

        // Stage 2: Apply pipeline selection and assign render group IDs to nodes
        var renderGroups = applyPipelineStage(rootNode)

        // Stage 3: Generate vertices for each render group
        renderGroups = applyVertexGenerationStage(renderGroups, rootNode)

        // Stage 4: Build render commands for each render group
        renderGroups = applyRenderCommandStage(renderGroups, rootNode)

        return CompiledScene(rootNode: rootNode, renderGroups: renderGroups)
    }

    private func applyTransformStage(_ rootNode: any AbstractDrawableNode) -> any AbstractDrawableNode {
        // Apply hardcoded transform visitors
        // theres no reason to do this - just to demo how you could add your
        // own transformation stage.
        var rotationVisitor = PlaneRotationVisitor(angle: .pi / 4, axis: [0, 0, 1])
        let _ = rotationVisitor.visit(rootNode)
        return rootNode
    }

    private func applyPipelineStage(_ rootNode: any AbstractDrawableNode) -> [UUID: RenderGroup] {
        // Use visitor to assign render group IDs to nodes
        return RenderGroupAssignmentVisitor.assignRenderGroups(to: rootNode)
    }

    private func applyVertexGenerationStage(_ renderGroups: [UUID: RenderGroup],
                                          _ rootNode: any AbstractDrawableNode) -> [UUID: RenderGroup] {
        var updatedGroups = renderGroups

        for (groupID, renderGroup) in renderGroups {
            // Collect all nodes that belong to this render group
            let nodesInGroup = collectNodesForGroup(groupID, from: rootNode)

            // Generate vertices for all nodes in this group
            let groupVertices = generateVerticesForGroup(nodesInGroup)

            // Update the render group with generated vertices
            var updatedGroup = renderGroup
            updatedGroup.vertices = groupVertices
            updatedGroups[groupID] = updatedGroup
        }

        return updatedGroups
    }

    private func applyRenderCommandStage(_ renderGroups: [UUID: RenderGroup],
                                       _ rootNode: any AbstractDrawableNode) -> [UUID: RenderGroup] {
        var updatedGroups = renderGroups

        for (groupID, renderGroup) in renderGroups {
            guard let vertices = renderGroup.vertices else { continue }

            // Collect nodes for this group
            let nodesInGroup = collectNodesForGroup(groupID, from: rootNode)

            // Generate draw commands based on vertices and node types
            let drawCommands = generateDrawCommands(for: nodesInGroup, vertices: vertices)

            // Update the render group with draw commands
            var updatedGroup = renderGroup
            updatedGroup.drawCommands = drawCommands
            updatedGroups[groupID] = updatedGroup
        }

        return updatedGroups
    }

    // MARK: Helper Methods

    private func collectNodesForGroup(_ groupID: UUID, from rootNode: any AbstractDrawableNode) -> [any AbstractDrawableNode] {
        // Collect all drawable nodes from the scene
        let allNodes = DrawableCollectorVisitor.collectDrawables(from: rootNode)

        // Filter nodes that belong to this specific render group
        // For now, return all nodes as we need to implement proper group tracking
        // TODO: Implement proper group filtering based on render group assignments
        return allNodes
    }

    private func generateVerticesForGroup(_ nodes: [any AbstractDrawableNode]) -> [PlotDSLVertex] {
        var allVertices: [PlotDSLVertex] = []

        for node in nodes {
            // Use VertexGeneratorVisitor to ensure vertices are generated
            VertexGeneratorVisitor.generateVertices(for: node)

            // Collect the generated vertices
            if let drawableNode = node as? any DrawableNode {
                let vertices = drawableNode.generateUnifiedVertices()
                allVertices.append(contentsOf: vertices)
            }
        }

        return allVertices
    }

    private func generateDrawCommands(for nodes: [any AbstractDrawableNode],
                                    vertices: [PlotDSLVertex]) -> [DrawCommand] {
        var commands: [DrawCommand] = []
        var vertexOffset = 0

        for node in nodes {
            if let drawableNode = node as? any DrawableNode {
                let nodeVertices = drawableNode.generateUnifiedVertices()
                let vertexCount = nodeVertices.count

                if vertexCount > 0 {
                    // Determine primitive type based on node type
                    let primitiveType: MTLPrimitiveType
                    if node is Line2D || node is Line3D {
                        primitiveType = .line
                    } else {
                        primitiveType = .triangle
                    }

                    let command = DrawCommand(
                        primitiveType: primitiveType,
                        vertexStart: vertexOffset,
                        vertexCount: vertexCount
                    )
                    commands.append(command)
                    vertexOffset += vertexCount
                }
            }
        }

        return commands
    }
}
