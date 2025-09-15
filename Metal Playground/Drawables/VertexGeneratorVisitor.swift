//
//  VertexGeneratorVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation

struct VertexGeneratorVisitor: AbstractDrawableVisitor {
    typealias Result = Void

    func visitSelf(_ plane: Plane) -> Void? {
        guard !plane.hasVertices() else { return nil }
        let vertices = plane.generateUnifiedVertices()
        try? plane.setVertices(vertices)
        return nil
    }

    func visitSelf(_ planeNode: PlaneNode) -> Void? {
        // PlaneNode doesn't implement DrawableNode, so no vertex generation needed
        return nil
    }

    func visitSelf(_ line: Line3D) -> Void? {
        guard !line.hasVertices() else { return nil }
        let vertices = line.generateUnifiedVertices()
        try? line.setVertices(vertices)
        return nil
    }

    func visitSelf(_ line: Line2D) -> Void? {
        guard !line.hasVertices() else { return nil }
        let vertices = line.generateUnifiedVertices()
        try? line.setVertices(vertices)
        return nil
    }

    // Generate and store vertices in all drawable nodes in scene graph
    func generateVerticesFor(_ nodes: [any AbstractDrawableNode]) {
        for node in nodes {
            let _ = node.accept(self)
        }
    }

    // Static convenience methods
    static func generateVertices(for nodes: [any AbstractDrawableNode]) {
        let generator = VertexGeneratorVisitor()
        generator.generateVerticesFor(nodes)
    }

    static func generateVertices(for node: any AbstractDrawableNode) {
        let generator = VertexGeneratorVisitor()
        let _ = node.accept(generator)
    }
}