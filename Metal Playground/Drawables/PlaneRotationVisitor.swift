//
//  PlaneRotationVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd

struct PlaneRotationVisitor: AbstractDrawableVisitor {
    typealias Result = Void

    let angle: Float
    let axis: SIMD3<Float>

    init(angle: Float, axis: SIMD3<Float>) {
        self.angle = angle
        self.axis = axis
    }

    // Override specifically for Plane - applies rotation to all planes
    func visitSelf(_ plane: Plane) -> Void? {
        let rotation = simd_float4x4(simd_quaternion(angle, axis))
        plane.applyTransform(rotation)
        return nil
    }

    // Override specifically for PlaneNode - applies rotation to all plane nodes
    func visitSelf(_ planeNode: PlaneNode) -> Void? {
        let rotation = simd_float4x4(simd_quaternion(angle, axis))
        planeNode.applyTransform(rotation)
        return nil
    }
}

// Example usage in pipeline
struct TransformPipeline {
    func applyRotations(to nodes: [any AbstractDrawableNode], angle: Float = .pi/4) {
        let rotationVisitor = PlaneRotationVisitor(angle: angle, axis: [0, 0, 1])

        for node in nodes {
            node.accept(rotationVisitor)
        }
    }
}