//
//  DrawableCompiler.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd

class DrawableCompiler {

    func compile(_ rootNode: any AbstractDrawableNode) -> CompiledScene {
        // Stage 1: Apply transform visitors
        applyTransformStage(rootNode)

        // Stage 2: Apply pipeline selection and group nodes
        let renderGroups = applyPipelineStage(rootNode)

        return CompiledScene(renderGroups: renderGroups)
    }

    private func applyTransformStage(_ rootNode: any AbstractDrawableNode) {
        // Apply hardcoded transform visitors
        let rotationVisitor = PlaneRotationVisitor(angle: .pi / 4, axis: [0, 0, 1])

        // Traverse entire scene graph and apply transforms
        traverseAndVisit(rootNode, with: rotationVisitor)
    }

    private func applyPipelineStage(_ rootNode: any AbstractDrawableNode) -> [RenderGroup] {
        // Collect all drawable nodes from scene graph
        let allNodes = collectAllNodes(rootNode)

        // Group nodes by pipeline requirements
        return groupNodesByPipeline(allNodes)
    }

    private func traverseAndVisit(_ node: any AbstractDrawableNode, with visitor: any AbstractDrawableVisitor) {
        // Visit current node
        _ = node.accept(visitor)

        // Recursively visit children
        for child in node.children {
            traverseAndVisit(child, with: visitor)
        }
    }

    private func collectAllNodes(_ rootNode: any AbstractDrawableNode) -> [any AbstractDrawableNode] {
        var allNodes: [any AbstractDrawableNode] = []

        func traverse(_ node: any AbstractDrawableNode) {
            // Skip the root container, include actual drawable nodes
            if !(node is SceneRootNode) {
                allNodes.append(node)
            }

            // Traverse children
            for child in node.children {
                traverse(child)
            }
        }

        traverse(rootNode)
        return allNodes
    }

    private func groupNodesByPipeline(_ nodes: [any AbstractDrawableNode]) -> [RenderGroup] {
        var groups: [DrawablePipelineDescriptor: [any AbstractDrawableNode]] = [:]

        for node in nodes {
            let pipeline = selectPipeline(for: node)

            if groups[pipeline] == nil {
                groups[pipeline] = []
            }
            groups[pipeline]?.append(node)
        }

        return groups.map { (pipeline, nodes) in
            RenderGroup(pipelineDescriptor: pipeline, nodes: nodes)
        }
    }

    private func selectPipeline(for node: any AbstractDrawableNode) -> DrawablePipelineDescriptor {
        // Hardcoded pipeline selection logic
        switch node {
        case is Plane:
            return DrawablePipelineDescriptor(
                vertexFunction: "vertex_main",
                fragmentFunction: "fragment_main"
            )
        case is PlaneNode:
            return DrawablePipelineDescriptor(
                vertexFunction: "vertex_main",
                fragmentFunction: "fragment_main"
            )
        case is Line3D, is Line2D:
            return DrawablePipelineDescriptor(
                vertexFunction: "line_vertex",
                fragmentFunction: "line_fragment"
            )
        default:
            return DrawablePipelineDescriptor(
                vertexFunction: "default_vertex",
                fragmentFunction: "default_fragment"
            )
        }
    }
}