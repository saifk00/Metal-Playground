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
