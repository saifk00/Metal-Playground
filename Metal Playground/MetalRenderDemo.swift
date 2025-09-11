//
//  MetalRenderDemo.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-10.
//


import SwiftUI
import simd
import MetalKit

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

        guard let runnable = demoCache[mode] else {
            enc.endEncoding()
            cb.present(drawable)
            cb.commit()
            return
        }
  
        enc.setRenderPipelineState(runnable.pipeline)
        runnable.runner.draw(with: enc)
        
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
