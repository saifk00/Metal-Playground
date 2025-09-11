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
        
        render(into: rpd, presenting: drawable, mode: Demo.Quad)
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

        let runnable = demoCache[mode]
        enc.setRenderPipelineState(runnable!.pipeline)
        runnable!.runner.draw(with: enc)
        
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

    var demoCache: [Demo : Runnable] = [:]
    
    init(for device: MTLDevice, with queue: MTLCommandQueue) throws {
        self.device = device
        self.queue = queue

        var triangleDemo = TriangleDemo()
        let trianglePipeline = triangleDemo.initPipeline(for: device)
        triangleDemo.initBuffers(for: device)
        
        
        var flatQuadDemo = QuadDemo()
        let flatQuadPipeline = flatQuadDemo.initPipeline(for: device)
        flatQuadDemo.initBuffers(for: device)
        
        demoCache[.Triangle] = Runnable(pipeline: trianglePipeline, runner: triangleDemo)
        demoCache[.Quad] = Runnable(pipeline: flatQuadPipeline, runner: flatQuadDemo)
    }
}

struct Runnable {
    let pipeline: MTLRenderPipelineState
    let runner: DemoRunner
}

#Preview {
    ContentView()
}
