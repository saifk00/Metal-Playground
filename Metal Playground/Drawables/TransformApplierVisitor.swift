//
//  TransformApplierVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation
import simd

struct TransformApplierVisitor: AbstractDrawableVisitor {
    typealias Result = Void

    func visitSelf(_ plane: Plane) -> Void? {
        let transform = plane.getWorldTransform()
        plane.applyVertexTransform(transform)
        return nil
    }

    func visitSelf(_ planeNode: PlaneNode) -> Void? {
        let transform = planeNode.getWorldTransform()
        planeNode.applyVertexTransform(transform)
        return nil
    }

    func visitSelf(_ line: Line3D) -> Void? {
        let transform = line.getWorldTransform()
        line.applyVertexTransform(transform)
        return nil
    }

    func visitSelf(_ line: Line2D) -> Void? {
        let transform = line.getWorldTransform()
        line.applyVertexTransform(transform)
        return nil
    }

    // Apply world transforms to stored vertices in all nodes
    func applyTransformsTo(_ nodes: [any AbstractDrawableNode]) {
        for node in nodes {
            let _ = node.accept(self)
        }
    }

    // Static convenience methods
    static func applyTransforms(to nodes: [any AbstractDrawableNode]) {
        let applier = TransformApplierVisitor()
        applier.applyTransformsTo(nodes)
    }

    static func applyTransforms(to node: any AbstractDrawableNode) {
        let applier = TransformApplierVisitor()
        let _ = node.accept(applier)
    }
}