//
//  RenderGroupAssignmentVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation
import simd

class RenderGroupAssignmentVisitor: BaseDrawableVisitor<Void> {
    typealias Result = Void

    private var pipelineToGroupID: [DrawablePipelineDescriptor: UUID] = [:]
    private var renderGroups: [UUID: RenderGroup] = [:]


    override func visitSelf(_ obj: any AbstractDrawableNode) -> Void? {
        let pipeline = PipelineSelector.selectPipeline(for: obj)
        assignRenderGroup(to: obj, pipeline: pipeline)
        return nil
    }

    private func assignRenderGroup(to node: any AbstractDrawableNode, pipeline: DrawablePipelineDescriptor) {
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
        let visitor = RenderGroupAssignmentVisitor()
        let _ = visitor.visit(rootNode)  // Use visit() for proper tree traversal
        return visitor.renderGroups
    }
}
