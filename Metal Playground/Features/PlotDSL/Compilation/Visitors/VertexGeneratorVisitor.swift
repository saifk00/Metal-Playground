//
//  VertexGeneratorVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation
import simd

class VertexGeneratorVisitor: BaseDrawableVisitor<Void> {
    typealias Result = Void

    override func visitSelf(_ plane: Plane) -> Void? {
        guard !plane.hasVertices() else { return nil }
        let vertices = plane.generateUnifiedVertices()
        try? plane.setVertices(vertices)
        return nil
    }

    override func visitSelf(_ planeNode: PlaneNode) -> Void? {
        // PlaneNode doesn't implement DrawableNode, so no vertex generation needed
        return nil
    }

    override func visitSelf(_ line: Line3D) -> Void? {
        guard !line.hasVertices() else { return nil }
        let vertices = line.generateUnifiedVertices()
        try? line.setVertices(vertices)
        return nil
    }

    override func visitSelf(_ line: Line2D) -> Void? {
        guard !line.hasVertices() else { return nil }
        let vertices = line.generateUnifiedVertices()
        try? line.setVertices(vertices)
        return nil
    }


    static func generateVertices(for node: any AbstractDrawableNode) {
        var generator = VertexGeneratorVisitor()
        let _ = node.accept(&generator)
    }
}
