//
//  ContentView.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-08-31.
//

import SwiftUI
import simd
import MetalKit

struct ContentView: View {
    @State private var speed = 180.0
    @State private var color: NSColor = .systemPink
    var body: some View {
        VStack {
            Text("hello metal!")
            MetalRenderDemoView()
                .frame(width: 500, height: 500)
        }.padding()
    }
}

// TODO an NSViewRepresentable for the metal demo
struct MetalRenderDemoView : NSViewRepresentable {
    var demo : MetalRenderDemo
    var queue : MTLCommandQueue
    var device: MTLDevice
    init() {
        device = MTLCreateSystemDefaultDevice()!
        queue = device.makeCommandQueue()!
        demo = try! MetalRenderDemo(for: device, with: queue)
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.device = device
        mtkView.delegate = demo
        // this has to match the render pipeline
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.framebufferOnly = true
        mtkView.isPaused = false
        mtkView.clearColor = MTLClearColor(red: 0.5, green: 0.1, blue: 0.12, alpha: 1.0)
        mtkView.preferredFramesPerSecond = 60
        return mtkView
    }
    
    func updateNSView(_ mtkView: MTKView, context: Context) {
    }
    
}

struct MyVertex {
    let time: Float
    let position: SIMD3<Float>
    
    static func vertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        
        // notice that we directly subscript attributes rather than
        // initialize the list ourselves. this is because
        // metal defines a fixed max length of these arrays
        // and initializes them for us. so we modify them in place
        if let timeD = descriptor.attributes[0] {
            timeD.format = .float
            // the backslash is swift's "key path literal" syntax
            timeD.offset = MemoryLayout.offset(of: \MyVertex.time)!
            // notice that we have an option to interleave
            // attributes _across buffers_ (but why?)
            timeD.bufferIndex = 0
        }
        
        if let posD = descriptor.attributes[1] {
            posD.format = .float3
            posD.offset = MemoryLayout.offset(of: \MyVertex.position)!
            posD.bufferIndex = 0
        }
        
        if let buf0Layout = descriptor.layouts[0] {
            buf0Layout.stepFunction = .perVertex
            buf0Layout.stride = MemoryLayout<MyVertex>.stride
            // meaningless since stepFunction is pervertex,
            // but set it anyway for explicitness
            buf0Layout.stepRate = 1
        }
        
        return descriptor
    }
}

enum Demo {
    case Triangle
    case Quad
};

class MetalRenderDemo : NSObject, MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        return;
    }
    
    func draw(in view: MTKView) {
        guard
            let rpd = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable
        else { return }
        
        print (view.drawableSize);
        
        // TODO how to plumb time into here?
        render(into: rpd, presenting: drawable, mode: Demo.Triangle)
    }
    
    static func makePipelineDescriptor(for device: MTLDevice) -> MTLRenderPipelineDescriptor {
        let pipeline = MTLRenderPipelineDescriptor()

        // Q: why do you need a device to make a library?
        // A: the shaders need to be compiled _for this device_ to be used
        let library = device.makeDefaultLibrary()!
        
        pipeline.vertexFunction = library.makeFunction(name: "vertex_shader")!
        pipeline.fragmentFunction = library.makeFunction(name: "fragment_shader")!
        
        // this might seem redundant - we specify a pixel format for the render
        // pass descriptor too, and metal ensures that they match (throwing
        // an error if they dont). But remember
        // we might use this pipeline for many different passes! this pipeline
        // is compatible with any pass that uses rgba8Uint format for its
        // textures.
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipeline.vertexDescriptor = MyVertex.vertexDescriptor()
        
        return pipeline
    }
    
    static func makeFlatQuadPipeline(for device: MTLDevice) -> MTLRenderPipelineDescriptor {
        let pipeline = MTLRenderPipelineDescriptor()
        
        let library = device.makeDefaultLibrary()!
        
        pipeline.vertexFunction = library.makeFunction(name: "quad_vertex_shader")!
        pipeline.fragmentFunction = library.makeFunction(name: "quad_fragment_shader")!
        
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        // TODO theres no reason flatquad needs time
        pipeline.vertexDescriptor = MyVertex.vertexDescriptor()
        
        return pipeline
    }
    
    static func makePassDescriptor(for device: MTLDevice, with texture: MTLTexture) -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
 
        // ... we now tell metal that this descriptor has a color attachment
        //     at this location on the device.
        descriptor.colorAttachments[0].texture = texture
        // when you start rendering, load the texture, clear it with red. when done,
        // store the data back to that same texture
        descriptor.colorAttachments[0].loadAction = .clear
        // the values here are interpreted with respect to the pixelformat of the corresponding texture
        // since we are using rgbaUnorm, the ranges are [0,1]
        descriptor.colorAttachments[0].clearColor = .init(red: 1, green: 0.0, blue: 0.0, alpha: 0.5)
        descriptor.colorAttachments[0].storeAction = .store
        
        return descriptor
    }
    
    static func makeVerticesForTriangle(at time: Int) -> [MyVertex] {
        let t = Float(time)
        let triangleVertices: [MyVertex] = [
            MyVertex(time: t, position: SIMD3<Float>(-0.5, -0.5, 0.0)),
            MyVertex(time: t, position: SIMD3<Float>( 0.5, -0.5, 0.0)),
            MyVertex(time: t, position: SIMD3<Float>( 0.0,  0.5, 0.0))
        ]
        
        return triangleVertices
    }
    
    func render(into passDescriptor: MTLRenderPassDescriptor,
                presenting drawable: MTLDrawable,
                mode: Demo) {
        guard let cb = queue.makeCommandBuffer(),
              let enc = cb.makeRenderCommandEncoder(descriptor: passDescriptor)
        else { return }

        if (mode == Demo.Triangle) {
            enc.setRenderPipelineState(trianglePipeline)
            triangleDemo.draw(with: enc)
        } else if (mode == Demo.Quad) {
            enc.setRenderPipelineState(flatQuadPipeline)
            enc.setVertexBuffer(flatQuad, offset: 0, index: 0)
            enc.drawIndexedPrimitives(
                type:.triangle,
                indexCount: 6,
                indexType: .uint16,
                indexBuffer: flatQuadIdx,
                indexBufferOffset: 0)
        }
        
        enc.endEncoding()
        
        cb.present(drawable)
        cb.commit()
    }
    
    static func getCGImage(from texture: MTLTexture) -> CGImage? {
        let width = texture.width
        let height = texture.height
        let rowBytes = width * 4

        var pixels = [UInt8](repeating: 0, count: rowBytes * height)

        let region = MTLRegionMake2D(0, 0, width, height)
        texture.getBytes(&pixels,
                         bytesPerRow: rowBytes,
                         from: region,
                         mipmapLevel: 0)

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let ctx = CGContext(data: &pixels,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: rowBytes,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }

        return ctx.makeImage()
    }
    
    let device: MTLDevice
    let queue: MTLCommandQueue
    var triangleDemo: DemoRunner
    let trianglePipeline: MTLRenderPipelineState
    
    let flatQuadPipeline: MTLRenderPipelineState
    let flatQuad: MTLBuffer
    let flatQuadIdx: MTLBuffer
    let tResolution: Int = 360
    let t0: Double
    
    init(for device: MTLDevice, with queue: MTLCommandQueue) throws {
        self.t0 = Double(CACurrentMediaTime())
        self.device = device
        self.queue = queue
        // pipeline = how to draw
        triangleDemo = TriangleDemo()
        trianglePipeline = triangleDemo.initPipeline(for: device)
        triangleDemo.initBuffers(for: device)
        
        
        flatQuadPipeline = try device.makeRenderPipelineState(
            descriptor: MetalRenderDemo.makeFlatQuadPipeline(for: device))
        
        flatQuad = device.makeBuffer(bytes: [
            MyVertex(time: 0.0, position: SIMD3<Float>(-1, -1, 0)),
            MyVertex(time: 0.0, position: SIMD3<Float>(-1, 1, 0)),
            MyVertex(time: 0.0, position: SIMD3<Float>(1, 1, 0)),
            MyVertex(time: 0.0, position: SIMD3<Float>(1, -1, 0)),
        ], length: MemoryLayout<MyVertex>.stride * 4,
                                     options: [])!
        
        let indices: [UInt16] = [
            0, 1, 2,
            0, 2, 3
        ]
        
        flatQuadIdx = device.makeBuffer(bytes: indices, length: MemoryLayout<UInt16>.stride * 6,
                                        options: [])!;
    }
}

protocol DemoRunner {
    // before rendering, a caller will set the state to this pipelinestate
    func initPipeline(for device: MTLDevice) -> MTLRenderPipelineState
    mutating func initBuffers(for device: MTLDevice)
    func draw(with encoder: MTLRenderCommandEncoder)
}

struct TriangleDemo : DemoRunner {
    let tResolution: Int = 360
    let t0: Double
    var triangleSequenceVertices: MTLBuffer?
    
    init() {
        t0 = Double(CACurrentMediaTime())
    }
    
    func initPipeline(for device: MTLDevice) -> MTLRenderPipelineState {
        let pipeline = MTLRenderPipelineDescriptor()

        // Q: why do you need a device to make a library?
        // A: the shaders need to be compiled _for this device_ to be used
        let library = device.makeDefaultLibrary()!
        
        pipeline.vertexFunction = library.makeFunction(name: "vertex_shader")!
        pipeline.fragmentFunction = library.makeFunction(name: "fragment_shader")!
        pipeline.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipeline.vertexDescriptor = MyVertex.vertexDescriptor()
        
        return try! device.makeRenderPipelineState(descriptor: pipeline)
    }
    
    mutating func initBuffers(for device: MTLDevice) {
        let times = Array(0...tResolution)
        let vertices: [MyVertex] = times.flatMap { t in
            MetalRenderDemo.makeVerticesForTriangle(at: t)
        }

        triangleSequenceVertices = device.makeBuffer(bytes: vertices,
                                             length: MemoryLayout<MyVertex>.stride * vertices.count,
                                             options: [])!
    }
    
    func draw(with encoder: MTLRenderCommandEncoder) {
        let time = Int(floor((CACurrentMediaTime() - self.t0) * 60.0))
        // 1. do the drawing
        let wrappedTime = time % tResolution
        encoder.setVertexBuffer(triangleSequenceVertices, offset: 0, index: 0)
        // we copied the vertex data maxT times, so we can just render the triangles
        // at time*3 to get the right time values
        encoder.drawPrimitives(type: .triangle, vertexStart: wrappedTime * 3, vertexCount: 3)
    }
}

#Preview {
    ContentView()
}
