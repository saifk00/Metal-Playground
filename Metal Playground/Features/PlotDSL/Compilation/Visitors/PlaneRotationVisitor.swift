//
//  PlaneRotationVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd

class PlaneRotationVisitor: BaseDrawableVisitor<AbstractDrawableNode> {
    typealias Result = AbstractDrawableNode

    let angle: Float
    let axis: SIMD3<Float>

    init(angle: Float, axis: SIMD3<Float>) {
        self.angle = angle
        self.axis = axis
    }

    override func visitSelf(_ plane: Plane) -> AbstractDrawableNode? {
        let rotation = simd_float4x4(simd_quaternion(angle, axis))
        plane.applyTransform(rotation)
        return plane
    }

    override func visitSelf(_ planeNode: PlaneNode) -> AbstractDrawableNode? {
        let rotation = simd_float4x4(simd_quaternion(angle, axis))
        planeNode.applyTransform(rotation)
        return planeNode
    }
}

// Example usage in pipeline
struct TransformPipeline {
    func applyRotations(to nodes: [any AbstractDrawableNode], angle: Float = .pi/4) {
        var rotationVisitor = PlaneRotationVisitor(angle: angle, axis: [0, 0, 1])

        for node in nodes {
            let _ = node.accept(&rotationVisitor)
        }
    }
}
