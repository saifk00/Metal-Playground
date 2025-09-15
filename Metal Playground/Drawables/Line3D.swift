//
//  Line3D.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd

class Line3D: DrawableNode, AbstractDrawableNode {
    typealias VertexType = PlotDSLVertex

    let from: Vector3D
    let to: Vector3D

    // Transform data (private, only accessible through API)
    private var worldTransform: simd_float4x4?

    init(from: Vector3D, to: Vector3D) {
        self.from = from
        self.to = to
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
        return [
            PlotDSLVertex(SIMD3<Float>(from)),
            PlotDSLVertex(SIMD3<Float>(to))
        ]
    }

    func generateUnifiedVertices() -> [PlotDSLVertex] {
        return generateVertices()
    }

    func vertexCount() -> Int { return 2 }

    var children: [any AbstractDrawableNode] { return [] }

    func accept<V: AbstractDrawableVisitor>(_ visitor: V) -> V.Result? {
        return visitor.visitSelf(self)
    }

    func isEqual(to other: Line3D) -> Bool {
        return self.from == other.from && self.to == other.to
    }
}
