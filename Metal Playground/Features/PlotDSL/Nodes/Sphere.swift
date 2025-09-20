//
//  Sphere.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-20.
//

import Foundation
import simd

class Sphere: DrawableNode, AbstractDrawableNode {
    typealias VertexType = PlotDSLVertex

    let center: Vector3D
    let radius: Float
    let segments: Int
    let rings: Int

    // Transform data (private, only accessible through API)
    private var worldTransform: simd_float4x4?

    // Vertex storage (single-set with safety constraints)
    private var storedVertices: [PlotDSLVertex]?

    // Render grouping (for GPU state optimization)
    var renderGroupID: UUID?

    init(center: Vector3D, radius: Float, segments: Int = 32, rings: Int = 16) {
        self.center = center
        self.radius = radius
        self.segments = segments
        self.rings = rings
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
        var vertices: [PlotDSLVertex] = []

        // Generate sphere vertices using spherical coordinates
        for ring in 0...rings {
            let phi = Float(ring) * Float.pi / Float(rings) // Latitude angle (0 to π)
            let y = cos(phi)
            let ringRadius = sin(phi)

            for segment in 0...segments {
                let theta = Float(segment) * 2.0 * Float.pi / Float(segments) // Longitude angle (0 to 2π)
                let x = ringRadius * cos(theta)
                let z = ringRadius * sin(theta)

                let position = SIMD3<Float>(
                    center.x + radius * x,
                    center.y + radius * y,
                    center.z + radius * z
                )

                vertices.append(PlotDSLVertex(position))
            }
        }

        // Generate triangle indices and create triangle vertices
        var triangleVertices: [PlotDSLVertex] = []

        for ring in 0..<rings {
            for segment in 0..<segments {
                let current = ring * (segments + 1) + segment
                let next = current + segments + 1

                // First triangle
                triangleVertices.append(vertices[current])
                triangleVertices.append(vertices[next])
                triangleVertices.append(vertices[current + 1])

                // Second triangle
                triangleVertices.append(vertices[current + 1])
                triangleVertices.append(vertices[next])
                triangleVertices.append(vertices[next + 1])
            }
        }

        return triangleVertices
    }

    func generateUnifiedVertices() -> [PlotDSLVertex] {
        return generateVertices()
    }

    func vertexCount() -> Int {
        return rings * segments * 6 // 2 triangles per quad, 3 vertices per triangle
    }

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

    func isEqual(to other: Sphere) -> Bool {
        return self.center == other.center && self.radius == other.radius
    }
}