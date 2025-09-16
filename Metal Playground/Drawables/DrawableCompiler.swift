//
//  DrawableCompiler.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd
import Foundation

class DrawableCompiler {

    func compile(_ rootNode: any AbstractDrawableNode) -> CompiledScene {
        // Stage 1: Apply transform visitors
        let _ = applyTransformStage(rootNode)

        // Stage 2: Apply pipeline selection and assign render group IDs to nodes
        let renderGroups = applyPipelineStage(rootNode)

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
        // Use visitor tgo assign render group IDs to nodes
        return RenderGroupAssignmentVisitor.assignRenderGroups(to: rootNode)
    }
}
