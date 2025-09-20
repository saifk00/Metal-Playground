//
//  Cylinder.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-20.
//

import Foundation
import simd

class Cylinder: DrawableNode, AbstractDrawableNode {
    typealias VertexType = PlotDSLVertex

    let base: Vector3D
    let top: Vector3D
    let radius: Float
    let segments: Int

    // Transform data (private, only accessible through API)
    private var worldTransform: simd_float4x4?

    // Vertex storage (single-set with safety constraints)
    private var storedVertices: [PlotDSLVertex]?

    // Render grouping (for GPU state optimization)
    var renderGroupID: UUID?

    init(base: Vector3D, top: Vector3D, radius: Float, segments: Int = 16) {
        self.base = base
        self.top = top
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

        // Calculate cylinder axis and perpendicular vectors
        let axis = SIMD3<Float>(top.x - base.x, top.y - base.y, top.z - base.z)
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
        let topCenter = SIMD3<Float>(top.x, top.y, top.z)

        // Generate base and top circle vertices
        var baseVertices: [SIMD3<Float>] = []
        var topVertices: [SIMD3<Float>] = []

        for i in 0..<segments {
            let angle = Float(i) * 2.0 * Float.pi / Float(segments)
            let offset = radius * (cos(angle) * perpendicular1 + sin(angle) * perpendicular2)

            baseVertices.append(baseCenter + offset)
            topVertices.append(topCenter + offset)
        }

        // Generate triangles for the cylinder sides
        for i in 0..<segments {
            let nextI = (i + 1) % segments

            // Two triangles per side face
            // Triangle 1: base[i] -> top[i] -> base[nextI]
            vertices.append(PlotDSLVertex(baseVertices[i]))
            vertices.append(PlotDSLVertex(topVertices[i]))
            vertices.append(PlotDSLVertex(baseVertices[nextI]))

            // Triangle 2: base[nextI] -> top[i] -> top[nextI]
            vertices.append(PlotDSLVertex(baseVertices[nextI]))
            vertices.append(PlotDSLVertex(topVertices[i]))
            vertices.append(PlotDSLVertex(topVertices[nextI]))
        }

        // Generate triangles for the base (fan triangulation)
        for i in 0..<segments {
            let nextI = (i + 1) % segments

            // Base triangle (winding for inward facing normal)
            vertices.append(PlotDSLVertex(baseCenter))
            vertices.append(PlotDSLVertex(baseVertices[nextI]))
            vertices.append(PlotDSLVertex(baseVertices[i]))
        }

        // Generate triangles for the top (fan triangulation)
        for i in 0..<segments {
            let nextI = (i + 1) % segments

            // Top triangle (winding for outward facing normal)
            vertices.append(PlotDSLVertex(topCenter))
            vertices.append(PlotDSLVertex(topVertices[i]))
            vertices.append(PlotDSLVertex(topVertices[nextI]))
        }

        return vertices
    }

    func generateUnifiedVertices() -> [PlotDSLVertex] {
        return generateVertices()
    }

    func vertexCount() -> Int {
        return segments * 12 // 6 vertices per side face (2 triangles), 3 per base triangle, 3 per top triangle
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

    func isEqual(to other: Cylinder) -> Bool {
        return self.base == other.base && self.top == other.top && self.radius == other.radius
    }
}