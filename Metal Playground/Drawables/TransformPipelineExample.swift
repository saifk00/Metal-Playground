//
//  TransformPipelineExample.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import simd

// Example of how the composable transform system works
struct TransformPipelineExample {

    static func demonstrateComposableTransforms() {
        // Create some drawable nodes
        let plane1 = Plane(normal: Vector3D(0, 0, 1), offset: Vector3D(0, 0, 0))
        let plane2 = PlaneNode(width: 2.0, height: 2.0)
        let nodes: [any AbstractDrawableNode] = [plane1, plane2]

        // Create transform visitors
        var rotationVisitor = PlaneRotationVisitor(angle: .pi/4, axis: [0, 0, 1])
        // Could add more visitors like:
        // let scaleVisitor = PlaneScaleVisitor(scale: 2.0)
        // let translationVisitor = PlaneTranslationVisitor(offset: [1, 0, 0])

        // Apply transforms - each visitor only affects nodes it cares about
        for node in nodes {
            let _ = node.accept(&rotationVisitor)
        }

        // Transforms are composable - applying another rotation multiplies with existing
        var secondRotation = PlaneRotationVisitor(angle: .pi/6, axis: [1, 0, 0])
        for node in nodes {
            let _ = node.accept(&secondRotation)
        }

        // Access final transforms
        print("Plane1 final transform: \(plane1.getWorldTransform())")
        print("PlaneNode final transform: \(plane2.getWorldTransform())")
    }
}

// This demonstrates the key benefits:
// 1. No fatalError - visitors just operate on nodes they understand
// 2. Composable - multiple transforms multiply together automatically
// 3. Type-safe - each visitor can override visitSelf for specific node types
// 4. Clean API - transforms are applied via applyTransform(), not direct property access
// 5. Extensible - easy to add new transform types and node types