//
//  SceneBasedPlotDemo.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation
import simd
import MetalKit

/**
 A scene based plot invokes the compiler to take the graph of abstract drawable nodes and perform the following high level steps:
 1. Perform any unwrapping to 'basic' drawables, including transforms
 2. Create RenderGroups by assigning a render group ID to each drawable object. objects in a render group share a vertex format
 3. Generate vertices according to the render group and coalesce them into buffers, and build up a set of commands that will be used to render the group
 4. When asked to draw into an encoder, use the commands built up in step 3 to render each object (using a common z-buffer for depth testing)
 */
struct SceneBasedPlotDemo: DemoRunner {
    private var plot: Plot

    var clearColor: MTLClearColor {
        return MTLClearColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0) // Very dark blue/black for 3D plots
    }

    // This demo manages its own pipeline states through the Plot's scene rendering system
    var managesOwnPipelineStates: Bool { true }

    init() {
        // Create a sample plot using the DSL
        plot = Plot {
            // A plane in 3D space
            Plane(normal: Vector3D(1, 1, 1), offset: Vector3D(0.1, 0.1, 0.1), size: 1)
            
            // 3D Coordinate axes
            Line3D(from: Vector3D(-0.8, 0.0, 0.0), to: Vector3D(0.8, 0.0, 0.0))  // X-axis (red conceptually)
            Line3D(from: Vector3D(0.0, -0.8, 0.0), to: Vector3D(0.0, 0.8, 0.0))  // Y-axis (green conceptually)
            Line3D(from: Vector3D(0.0, 0.0, -0.8), to: Vector3D(0.0, 0.0, 0.8))  // Z-axis (blue conceptually)

            // Spheres at the positive ends of axes
            Sphere(center: Vector3D(0.8, 0.0, 0.0), radius: 0.05, segments: 16, rings: 8)   // X-axis positive end
            Sphere(center: Vector3D(0.0, 0.8, 0.0), radius: 0.05, segments: 16, rings: 8)   // Y-axis positive end
            Sphere(center: Vector3D(0.0, 0.0, 0.8), radius: 0.05, segments: 16, rings: 8)   // Z-axis positive end

            // Cones at the negative ends of axes
            Cone(base: Vector3D(-0.85, 0.0, 0.0), tip: Vector3D(-0.8, 0.0, 0.0), radius: 0.04, segments: 12)  // X-axis negative end
            Cone(base: Vector3D(0.0, -0.85, 0.0), tip: Vector3D(0.0, -0.8, 0.0), radius: 0.04, segments: 12)  // Y-axis negative end
            Cone(base: Vector3D(0.0, 0.0, -0.85), tip: Vector3D(0.0, 0.0, -0.8), radius: 0.04, segments: 12)  // Z-axis negative end
            
            Plane(normal: Vector3D(1, 1, 1), offset: Vector3D(-0.1, -0.1, -0.1), size: 1)
        }
    }

    func initPipeline(for device: MTLDevice) -> MTLRenderPipelineState? {
        // This demo manages its own pipeline states, so return nil
        // Pipeline setup is handled during initBuffers
        return nil
    }

    mutating func initBuffers(for device: MTLDevice) {
        // Delegate to the Plot's setup methods
        do {
            try plot.setupPipeline(device: device)
            try plot.setupBuffers(device: device)
        } catch {
            fatalError("Error setting up plot: \(error)")
        }
    }

    func draw(with encoder: MTLRenderCommandEncoder) {
        // This method won't be used since we use drawWithPipelineManagement instead
        // But required by protocol
        plot.render(with: encoder)
    }

    func drawWithPipelineManagement(with encoder: MTLRenderCommandEncoder, device: MTLDevice) {
        // Delegate to the Plot's render method, which manages its own pipeline states
        plot.render(with: encoder)
    }
}
