//
//  PlotDemo.swift  
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd
import MetalKit

struct PlotDemo: DemoRunner {
    private var vertexBuffer: MTLBuffer!
    private var plot: Plot
    
    var clearColor: MTLClearColor {
        return MTLClearColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0) // Very dark blue/black for 3D plots
    }
    
    init() {
        // Create a sample plot using the DSL
        
        /*
         Goal - write code like
         Plot {
            Line(from: Point(0.2, 4), to: Point(0.5, 0.5))
         }.axes(.x, .y)
         
         Plot3D {
            Plane(normal: Vector(1, 2, 3), offset: Vector(2, 4))
            Trajectory(
                // a 1d vector rendered in 3d space assumes x=y=0
                (t) -> return Vector(3.1*t + 9.8/2.0 * pow(t, 2))) {
                InterestingPoint(t: 0)
                InterestingPoint(t: 2.5)
                InterestingPoint(t: 5.0)
            }.animation(
                from: 0,
                to: 5,
                easing: .bounceIn)
            
            VectorField2D((r, theta) -> return Polar(I/r^2, theta))
                .coloringStyle(.temperature)
         }
         */
        
        plot = Plot {
            // 3D Coordinate axes
            Line3D(from: Vector3D(-0.8, 0.0, 0.0), to: Vector3D(0.8, 0.0, 0.0))  // X-axis (red conceptually)
            Line3D(from: Vector3D(0.0, -0.8, 0.0), to: Vector3D(0.0, 0.8, 0.0))  // Y-axis (green conceptually)
            Line3D(from: Vector3D(0.0, 0.0, -0.8), to: Vector3D(0.0, 0.0, 0.8))  // Z-axis (blue conceptually)
            
            // A plane in 3D space
            Plane(normal: Vector3D(1, 1, 1), offset: Vector3D(0.1, 0.1, 0.1), size: 1)
        }
    }
    
    func initPipeline(for device: MTLDevice) -> MTLRenderPipelineState? {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Could not create default library")
        }
        
        let vertexFunction = library.makeFunction(name: "plot_vertex_shader")!
        let fragmentFunction = library.makeFunction(name: "plot_fragment_shader")!
        
        let renderPipelineDescriptor = MTLRenderPipelineDescriptor()
        renderPipelineDescriptor.vertexFunction = vertexFunction
        renderPipelineDescriptor.fragmentFunction = fragmentFunction
        renderPipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        renderPipelineDescriptor.vertexDescriptor = PlotDSLVertex.vertexDescriptor()
        
        do {
            return try device.makeRenderPipelineState(descriptor: renderPipelineDescriptor)
        } catch {
            fatalError("Error creating pipeline state: \(error)")
        }
    }
    
    mutating func initBuffers(for device: MTLDevice) {
        let vertices = plot.generateAllVertices()
        let vertexBufferLength = vertices.count * MemoryLayout<PlotDSLVertex>.size
        
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertexBufferLength, options: [])
        vertexBuffer.label = "PlotVertices"
    }
    
    func draw(with encoder: MTLRenderCommandEncoder) {
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Draw different primitive types for different elements
        var vertexOffset = 0
        
        for element in plot.elements {
            let vertexCount = element.vertexCount()
            
            if element is Line2D || element is Line3D {
                // Draw lines
                encoder.drawPrimitives(type: .line, vertexStart: vertexOffset, vertexCount: vertexCount)
            } else if element is Plane {
                // Draw triangles for planes
                encoder.drawPrimitives(type: .triangle, vertexStart: vertexOffset, vertexCount: vertexCount)
            }
            
            vertexOffset += vertexCount
        }
    }
}
