//
//  VertexGeneratorVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation

struct VertexGeneratorVisitor: AbstractDrawableVisitor {
    typealias Result = [PlotDSLVertex]

    func visitSelf(_ plane: Plane) -> [PlotDSLVertex]? {
        return plane.generateUnifiedVertices()
    }

    func visitSelf(_ planeNode: PlaneNode) -> [PlotDSLVertex]? {
        return planeNode.generateUnifiedVertices()
    }

    func visitSelf(_ line: Line3D) -> [PlotDSLVertex]? {
        return line.generateUnifiedVertices()
    }

    func visitSelf(_ line: Line2D) -> [PlotDSLVertex]? {
        return line.generateUnifiedVertices()
    }

    // Collect vertices from all drawable nodes in scene graph
    func collectVerticesFrom(_ nodes: [any AbstractDrawableNode]) -> [PlotDSLVertex] {
        var allVertices: [PlotDSLVertex] = []

        for node in nodes {
            if let vertices = node.accept(self) {
                allVertices.append(contentsOf: vertices)
            }
        }

        return allVertices
    }
}