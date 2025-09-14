//
//  TransformVisitorTests.swift
//  Metal PlaygroundTests
//
//  Created by Claude on 2025-09-13.
//

import XCTest
import simd
@testable import Metal_Playground

final class TransformVisitorTests: XCTestCase {

    func testSingleDrawableTransform() {
        // Create a simple plane
        let plane = Plane(normal: Vector3D(0, 1, 0), offset: Vector3D(0, 0, 0), size: 2.0)

        // Create transform visitor
        let visitor = TransformApplyingVisitor()

        // Apply visitor to plane
        let result = plane.accept(visitor)
        
        // TODO these should be the same
        XCTAssert(result == PlacedDrawable(plane))
    }

    func testPlotWithChildren() {
        // Create a plot with children
        let plot = Plot {
            // 3D Coordinate axes
            Line3D(from: Vector3D(-0.8, 0.0, 0.0), to: Vector3D(0.8, 0.0, 0.0))  // X-axis
            Line3D(from: Vector3D(0.0, -0.8, 0.0), to: Vector3D(0.0, 0.8, 0.0))  // Y-axis
            Line3D(from: Vector3D(0.0, 0.0, -0.8), to: Vector3D(0.0, 0.0, 0.8))  // Z-axis
        }

        let visitor = TransformApplyingVisitor()
        let result = visitor.visit(plot)
        
        XCTAssert(result == PlacedDrawable(plot))
    }
}
