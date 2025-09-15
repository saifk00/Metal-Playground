//
//  SceneRootNode.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd

class SceneRootNode: AbstractDrawableNode {
    private let childNodes: [any AbstractDrawableNode]

    // Transform data (private, only accessible through API)
    private var worldTransform: simd_float4x4?

    // Vertex storage (single-set with safety constraints)
    private var storedVertices: [PlotDSLVertex]?

    init(children: [any DrawableNode]) {
        // Convert DrawableNodes to AbstractDrawableNodes
        self.childNodes = children.compactMap { $0 as? AbstractDrawableNode }
    }

    var children: [any AbstractDrawableNode] { childNodes }

    // Composable transform API implementation
    func applyTransform(_ transform: simd_float4x4) {
        let current = worldTransform ?? matrix_identity_float4x4
        worldTransform = current * transform
    }

    func getWorldTransform() -> simd_float4x4 {
        return worldTransform ?? matrix_identity_float4x4
    }

    func accept<V: AbstractDrawableVisitor>(_ visitor: V) -> V.Result? {
        return visitor.visitSelf(self)
    }

    // Vertex storage API implementation (SceneRootNode typically doesn't store vertices)
    func setVertices(_ vertices: [PlotDSLVertex]) throws {
        guard storedVertices == nil else {
            throw VertexStorageError.verticesAlreadySet
        }
        storedVertices = vertices
    }

    func getVertices() -> [PlotDSLVertex]? {
        return storedVertices
    }

    func hasVertices() -> Bool {
        return storedVertices != nil
    }

    func applyVertexTransform(_ transform: simd_float4x4) {
        guard var vertices = storedVertices else { return }

        vertices = vertices.map { vertex in
            var transformedVertex = vertex
            let transformedPosition = transform * SIMD4<Float>(vertex.position.x, vertex.position.y, vertex.position.z, 1.0)
            transformedVertex.position = SIMD3<Float>(transformedPosition.x, transformedPosition.y, transformedPosition.z)
            return transformedVertex
        }

        storedVertices = vertices
    }
}

// Add SceneRootNode support to visitors
extension AbstractDrawableVisitor {
    func visitSelf(_ sceneRoot: SceneRootNode) -> Result? {
        return nil // Default implementation - most visitors ignore the root
    }
}