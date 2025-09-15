//
//  RenderPipelineCoordinator.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd
import Metal

struct RenderPipelineCoordinator {

    // Example pipeline that applies transforms and selects pipelines
    func processNodes(_ nodes: [any AbstractDrawableNode]) {
        // Stage 1: Apply all transform visitors (mutates nodes in place)
        applyTransforms(nodes)

        // Stage 2: Apply pipeline selection (could add pipeline info to nodes)
        // applyPipelineSelection(nodes)
    }

    private func applyTransforms(_ nodes: [any AbstractDrawableNode]) {
        // Apply multiple transform visitors in sequence
        let rotationVisitor = PlaneRotationVisitor(
            angle: .pi / 4,
            axis: [0, 0, 1]
        )

        // Visit all nodes - visitors will only transform the ones they care about
        for node in nodes {
            node.accept(rotationVisitor)
        }

        // Could apply more visitors in sequence
        // let scaleVisitor = PlaneScaleVisitor(scale: 2.0)
        // for node in nodes {
        //     node.accept(scaleVisitor)
        // }
    }

    // Future: Could add pipeline selection visitors here
    // private func applyPipelineSelection(_ nodes: [any AbstractDrawableNode]) {
    //     let pipelineVisitor = BasicPipelineSelector()
    //     for node in nodes {
    //         node.accept(pipelineVisitor)
    //     }
    // }
}

// Usage example:
// let coordinator = RenderPipelineCoordinator()
// let plane = PlaneNode(width: 2.0, height: 2.0)
// let pipelined = coordinator.processNodes([plane])
// print(pipelined[0].worldTransform) // Has rotation applied
// print(pipelined[0].pipelineDescriptor) // Has pipeline selected
