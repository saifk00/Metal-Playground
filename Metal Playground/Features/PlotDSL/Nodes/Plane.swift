//
//  Plane.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd

class Plane: DrawableNode, AbstractDrawableNode {
    typealias VertexType = PlotDSLVertex

    let n: SIMD3<Float>
    let offset: SIMD3<Float>
    let size: Float  // Side length of plane square

    // Transform data (private, only accessible through API)
    private var worldTransform: simd_float4x4?

    // Vertex storage (single-set with safety constraints)
    private var storedVertices: [PlotDSLVertex]?

    // Render grouping (for GPU state optimization)
    var renderGroupID: UUID?

    init(normal: Vector3D, offset: Vector3D, size: Float = 1.0) {
        self.n = normalize(normal.simd)
        self.offset = SIMD3<Float>(offset)
        self.size = size
    }

    // Composable transform API implementation
    func applyTransform(_ transform: simd_float4x4) {
        let current = worldTransform ?? matrix_identity_float4x4
        worldTransform = current * transform
    }

    func getWorldTransform() -> simd_float4x4 {
        return worldTransform ?? matrix_identity_float4x4
    }
    
    func generateVertices() -> [PlotDSLVertex] {
        // Find two orthogonal vectors to the normal
        var u: SIMD3<Float>
        if abs(n.x) < 0.9 {
            u = normalize(cross(n, SIMD3<Float>(1, 0, 0)))
        } else {
            u = normalize(cross(n, SIMD3<Float>(0, 1, 0)))
        }
        let v = cross(n, u)
        
        // Create plane vertices centered at offset
        let halfSize = size * 0.5
        
        let corners: [SIMD3<Float>] = [
            offset + halfSize * (-u - v),  // Bottom-left
            offset + halfSize * (u - v),   // Bottom-right
            offset + halfSize * (u + v),   // Top-right
            offset + halfSize * (-u + v)   // Top-left
        ]
        
        // Generate triangles for the plane (two triangles make a quad)
        let blueColor = SIMD4<Float>(0, 0, 1, 1)  // Solid blue
        return [
            // First triangle: bottom-left, bottom-right, top-left
            PlotDSLVertex(corners[0], color: blueColor),
            PlotDSLVertex(corners[1], color: blueColor),
            PlotDSLVertex(corners[3], color: blueColor),
            // Second triangle: bottom-right, top-right, top-left  
            PlotDSLVertex(corners[1], color: blueColor),
            PlotDSLVertex(corners[2], color: blueColor),
            PlotDSLVertex(corners[3], color: blueColor)
        ]
    }
    
    func generateUnifiedVertices() -> [PlotDSLVertex] {
        return generateVertices()
    }
    
    func vertexCount() -> Int { return 6 }  // 2 triangles = 6 vertices

    var children: [any AbstractDrawableNode] { return [] }

    func accept<V: AbstractDrawableVisitor>(_ visitor: inout V) -> V.Result? {
        return visitor.visitSelf(self)
    }

    // Vertex storage API implementation
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

    func isEqual(to other: Plane) -> Bool {
        return simd_equal(self.n, other.n) &&
               simd_equal(self.offset, other.offset) &&
               self.size == other.size
    }
}
