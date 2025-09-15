//
//  TransformApplierVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation
import simd

struct TransformApplierVisitor: AbstractDrawableVisitor {
    typealias Result = [PlotDSLVertex]

    // Store the base vertices that need transformation
    private let baseVertices: [PlotDSLVertex]
    private var currentVertexOffset = 0

    init(baseVertices: [PlotDSLVertex]) {
        self.baseVertices = baseVertices
    }

    mutating func visitSelf(_ plane: Plane) -> [PlotDSLVertex]? {
        return applyTransformToNodeVertices(plane)
    }

    mutating func visitSelf(_ planeNode: PlaneNode) -> [PlotDSLVertex]? {
        return applyTransformToNodeVertices(planeNode)
    }

    mutating func visitSelf(_ line: Line3D) -> [PlotDSLVertex]? {
        return applyTransformToNodeVertices(line)
    }

    mutating func visitSelf(_ line: Line2D) -> [PlotDSLVertex]? {
        return applyTransformToNodeVertices(line)
    }

    private mutating func applyTransformToNodeVertices(_ node: any AbstractDrawableNode) -> [PlotDSLVertex] {
        guard let drawableNode = node as? any DrawableNode else { return [] }

        let vertexCount = drawableNode.vertexCount()
        guard currentVertexOffset + vertexCount <= baseVertices.count else { return [] }

        // Extract vertices for this node
        let nodeVertices = Array(baseVertices[currentVertexOffset..<(currentVertexOffset + vertexCount)])
        currentVertexOffset += vertexCount

        // Apply world transform to vertices
        let transform = node.getWorldTransform()
        let transformedVertices = nodeVertices.map { vertex in
            var transformedVertex = vertex
            let transformedPosition = transform * SIMD4<Float>(vertex.position.x, vertex.position.y, vertex.position.z, 1.0)
            transformedVertex.position = SIMD3<Float>(transformedPosition.x, transformedPosition.y, transformedPosition.z)
            return transformedVertex
        }

        return transformedVertices
    }

    // Apply transforms to all nodes and collect transformed vertices
    mutating func applyTransformsTo(_ nodes: [any AbstractDrawableNode]) -> [PlotDSLVertex] {
        var allTransformedVertices: [PlotDSLVertex] = []

        currentVertexOffset = 0  // Reset offset for each batch

        for node in nodes {
            if let transformedVertices = node.accept(self) {
                allTransformedVertices.append(contentsOf: transformedVertices)
            }
        }

        return allTransformedVertices
    }
}