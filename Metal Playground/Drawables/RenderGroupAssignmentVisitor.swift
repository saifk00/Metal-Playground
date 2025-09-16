//
//  RenderGroupAssignmentVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation
import simd

struct RenderGroupAssignmentVisitor: AbstractDrawableVisitor {
    typealias Result = Void

    private var pipelineToGroupID: [DrawablePipelineDescriptor: UUID] = [:]
    private var renderGroups: [UUID: RenderGroup] = [:]

    init() {}

    mutating func visitSelf(_ plane: Plane) -> Void? {
        assignRenderGroup(to: plane, pipeline: selectPipeline(for: plane))
        return nil
    }

    mutating func visitSelf(_ planeNode: PlaneNode) -> Void? {
        assignRenderGroup(to: planeNode, pipeline: selectPipeline(for: planeNode))
        return nil
    }

    mutating func visitSelf(_ line: Line3D) -> Void? {
        assignRenderGroup(to: line, pipeline: selectPipeline(for: line))
        return nil
    }

    mutating func visitSelf(_ line: Line2D) -> Void? {
        assignRenderGroup(to: line, pipeline: selectPipeline(for: line))
        return nil
    }

    mutating func visitSelf(_ sceneRoot: SceneRootNode) -> Void? {
        // Scene root doesn't get a render group - tree traversal is handled by visit() method
        return nil
    }

    private mutating func assignRenderGroup(to node: any AbstractDrawableNode, pipeline: DrawablePipelineDescriptor) {
        // Get or create group ID for this pipeline
        let groupID: UUID
        if let existingGroupID = pipelineToGroupID[pipeline] {
            groupID = existingGroupID
        } else {
            groupID = UUID()
            pipelineToGroupID[pipeline] = groupID
            renderGroups[groupID] = RenderGroup(groupID: groupID, pipelineDescriptor: pipeline)
        }

        // Assign the render group ID to the node
        node.renderGroupID = groupID
    }

    private func selectPipeline(for node: any AbstractDrawableNode) -> DrawablePipelineDescriptor {
        // Hardcoded pipeline selection logic
        switch node {
        case is Plane:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )
        case is PlaneNode:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )
        case is Line3D, is Line2D:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )
        default:
            return DrawablePipelineDescriptor(
                vertexFunction: "default_vertex",
                fragmentFunction: "default_fragment"
            )
        }
    }

    // Static convenience methods
    static func assignRenderGroups(to rootNode: any AbstractDrawableNode) -> [UUID: RenderGroup] {
        var visitor = RenderGroupAssignmentVisitor()
        let _ = visitor.visit(rootNode)  // Use visit() for proper tree traversal
        return visitor.renderGroups
    }
}