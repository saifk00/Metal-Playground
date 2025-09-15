//
//  PlaneNode.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd
import Metal

class PlaneNode: AbstractDrawableNode {
    // Core immutable data
    let width: Float
    let height: Float
    var children: [any AbstractDrawableNode] { [] }

    // Transform data (private, only accessible through API)
    private var worldTransform: simd_float4x4?

    init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }

    func accept<V: AbstractDrawableVisitor>(_ visitor: V) -> V.Result? {
        return visitor.visitSelf(self)
    }

    // Composable transform API implementation
    func applyTransform(_ transform: simd_float4x4) {
        let current = worldTransform ?? matrix_identity_float4x4
        worldTransform = current * transform
    }

    func getWorldTransform() -> simd_float4x4 {
        return worldTransform ?? matrix_identity_float4x4
    }
}

// Note: The progressive interface approach requires class-based nodes
// and integrated property storage. The AssociatedStorage approach
// cannot be implemented in extensions. This would need to be
// implemented within the class definition itself.

// Example of how this would work (conceptual):
// class PlaneNode: BufferedDrawableNode {
//     @AssociatedStorage var worldTransform: simd_float4x4?
//     @AssociatedStorage var pipelineDescriptor: DrawablePipelineDescriptor?
//     @AssociatedStorage var vertexRange: (offset: Int, count: Int)?
//     @AssociatedStorage var gpuBuffer: MTLBuffer?
// }
