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
        let pipeline = PipelineSelector.selectPipeline(for: plane)
        assignRenderGroup(to: plane, pipeline: pipeline)
        return nil
    }

    mutating func visitSelf(_ planeNode: PlaneNode) -> Void? {
        let pipeline = PipelineSelector.selectPipeline(for: planeNode)
        assignRenderGroup(to: planeNode, pipeline: pipeline)
        return nil
    }

    mutating func visitSelf(_ line: Line3D) -> Void? {
        let pipeline = PipelineSelector.selectPipeline(for: line)
        assignRenderGroup(to: line, pipeline: pipeline)
        return nil
    }

    mutating func visitSelf(_ line: Line2D) -> Void? {
        let pipeline = PipelineSelector.selectPipeline(for: line)
        assignRenderGroup(to: line, pipeline: pipeline)
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

    // Static convenience methods
    static func assignRenderGroups(to rootNode: any AbstractDrawableNode) -> [UUID: RenderGroup] {
        var visitor = RenderGroupAssignmentVisitor()
        let _ = visitor.visit(rootNode)  // Use visit() for proper tree traversal
        return visitor.renderGroups
    }
}
