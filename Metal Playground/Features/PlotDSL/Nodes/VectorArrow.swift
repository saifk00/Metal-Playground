//
//  VectorArrow.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-20.
//

import Foundation
import simd

class VectorArrow: DrawableNode, AbstractDrawableNode {
    typealias VertexType = PlotDSLVertex

    let origin: Vector3D
    let vector: Vector3D
    let shaftRadius: Float
    let arrowheadRadius: Float
    let arrowheadLength: Float
    let segments: Int

    // Transform data (private, only accessible through API)
    private var worldTransform: simd_float4x4?

    // Vertex storage (single-set with safety constraints)
    private var storedVertices: [PlotDSLVertex]?

    // Render grouping (for GPU state optimization)
    var renderGroupID: UUID?

    // Internal components
    private let cylinder: Cylinder
    private let cone: Cone

    init(origin: Vector3D, vector: Vector3D, shaftRadius: Float = 0.02, arrowheadRadius: Float? = nil, arrowheadLength: Float? = nil, segments: Int = 12) {
        self.origin = origin
        self.vector = vector
        self.shaftRadius = shaftRadius

        // Default arrowhead radius is 2x shaft radius
        self.arrowheadRadius = arrowheadRadius ?? (shaftRadius * 2.0)

        // Default arrowhead length is 5x shaft radius
        self.arrowheadLength = arrowheadLength ?? (shaftRadius * 5.0)

        self.segments = segments

        // Calculate the end point of the vector
        let vectorEnd = Vector3D(
            origin.x + vector.x,
            origin.y + vector.y,
            origin.z + vector.z
        )

        // Calculate the length of the vector
        let vectorLength = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)

        // Ensure arrow head doesn't exceed vector length
        let effectiveArrowheadLength = min(self.arrowheadLength, vectorLength * 0.3)

        // Calculate shaft end point (where arrowhead begins)
        let shaftRatio = max(0, (vectorLength - effectiveArrowheadLength) / vectorLength)
        let shaftEnd = Vector3D(
            origin.x + vector.x * shaftRatio,
            origin.y + vector.y * shaftRatio,
            origin.z + vector.z * shaftRatio
        )

        // Create cylinder for the shaft
        self.cylinder = Cylinder(
            base: origin,
            top: shaftEnd,
            radius: shaftRadius,
            segments: segments
        )

        // Create cone for the arrowhead
        self.cone = Cone(
            base: shaftEnd,
            tip: vectorEnd,
            radius: self.arrowheadRadius,
            segments: segments
        )
    }

    // Composable transform API implementation
    func applyTransform(_ transform: simd_float4x4) {
        let current = worldTransform ?? matrix_identity_float4x4
        worldTransform = current * transform

        // Apply transform to child components
        cylinder.applyTransform(transform)
        cone.applyTransform(transform)
    }

    func getWorldTransform() -> simd_float4x4 {
        return worldTransform ?? matrix_identity_float4x4
    }

    func generateVertices() -> [PlotDSLVertex] {
        var vertices: [PlotDSLVertex] = []

        // Generate vertices from cylinder and cone components
        vertices.append(contentsOf: cylinder.generateVertices())
        vertices.append(contentsOf: cone.generateVertices())

        return vertices
    }

    func generateUnifiedVertices() -> [PlotDSLVertex] {
        return generateVertices()
    }

    func vertexCount() -> Int {
        return cylinder.vertexCount() + cone.vertexCount()
    }

    var children: [any AbstractDrawableNode] {
        return [cylinder, cone]
    }

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

    func isEqual(to other: VectorArrow) -> Bool {
        return self.origin == other.origin &&
               self.vector == other.vector &&
               self.shaftRadius == other.shaftRadius &&
               self.arrowheadRadius == other.arrowheadRadius &&
               self.arrowheadLength == other.arrowheadLength
    }
}
