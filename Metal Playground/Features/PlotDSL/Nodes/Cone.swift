//
//  Cone.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-20.
//

import Foundation
import simd

class Cone: DrawableNode, AbstractDrawableNode {
    typealias VertexType = PlotDSLVertex

    let base: Vector3D
    let tip: Vector3D
    let radius: Float
    let segments: Int

    // Transform data (private, only accessible through API)
    private var worldTransform: simd_float4x4?

    // Vertex storage (single-set with safety constraints)
    private var storedVertices: [PlotDSLVertex]?

    // Render grouping (for GPU state optimization)
    var renderGroupID: UUID?

    init(base: Vector3D, tip: Vector3D, radius: Float, segments: Int = 16) {
        self.base = base
        self.tip = tip
        self.radius = radius
        self.segments = segments
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

        // Calculate cone axis and perpendicular vectors
        let axis = SIMD3<Float>(tip.x - base.x, tip.y - base.y, tip.z - base.z)
        let axisLength = length(axis)
        let normalizedAxis = normalize(axis)

        // Find two perpendicular vectors to the axis
        var perpendicular1: SIMD3<Float>
        if abs(normalizedAxis.x) < 0.9 {
            perpendicular1 = normalize(cross(normalizedAxis, SIMD3<Float>(1, 0, 0)))
        } else {
            perpendicular1 = normalize(cross(normalizedAxis, SIMD3<Float>(0, 1, 0)))
        }
        let perpendicular2 = cross(normalizedAxis, perpendicular1)

        let baseCenter = SIMD3<Float>(base.x, base.y, base.z)
        let tipPos = SIMD3<Float>(tip.x, tip.y, tip.z)

        // Generate base circle vertices
        var baseVertices: [SIMD3<Float>] = []
        for i in 0..<segments {
            let angle = Float(i) * 2.0 * Float.pi / Float(segments)
            let offset = radius * (cos(angle) * perpendicular1 + sin(angle) * perpendicular2)
            baseVertices.append(baseCenter + offset)
        }

        // Generate triangles for the cone surface
        for i in 0..<segments {
            let nextI = (i + 1) % segments

            // Side triangle from base edge to tip
            vertices.append(PlotDSLVertex(baseVertices[i]))
            vertices.append(PlotDSLVertex(baseVertices[nextI]))
            vertices.append(PlotDSLVertex(tipPos))
        }

        // Generate triangles for the base (fan triangulation)
        for i in 0..<segments {
            let nextI = (i + 1) % segments

            // Base triangle
            vertices.append(PlotDSLVertex(baseCenter))
            vertices.append(PlotDSLVertex(baseVertices[nextI]))
            vertices.append(PlotDSLVertex(baseVertices[i]))
        }

        return vertices
    }

    func generateUnifiedVertices() -> [PlotDSLVertex] {
        return generateVertices()
    }

    func vertexCount() -> Int {
        return segments * 6 // 3 vertices per triangle, 2 triangles per segment (side + base)
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

    func isEqual(to other: Cone) -> Bool {
        return self.base == other.base && self.tip == other.tip && self.radius == other.radius
    }
}