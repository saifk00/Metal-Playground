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
        else {
            return }
        render(into: rpd, presenting: drawable, mode: currentDemo)
    }

    
    func render(into passDescriptor: MTLRenderPassDescriptor,
                presenting drawable: MTLDrawable,
                mode: Demo) {
        guard let cb = queue.makeCommandBuffer(),
              let enc = cb.makeRenderCommandEncoder(descriptor: passDescriptor)
        else { 
            return 
        }

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
    var currentDemo: Demo = .Triangle

    var demoCache: [Demo : Runnable] = [:]
    
    func setCurrentDemo(_ demo: Demo) {
        currentDemo = demo
    }
    
    init(for device: MTLDevice, with queue: MTLCommandQueue) throws {
        self.device = device
        self.queue = queue

        var triangleDemo = TriangleDemo()
        let trianglePipeline = triangleDemo.initPipeline(for: device)
        triangleDemo.initBuffers(for: device)
        
        var flatQuadDemo = QuadDemo()
        let flatQuadPipeline = flatQuadDemo.initPipeline(for: device)
        flatQuadDemo.initBuffers(for: device)
        
        var plotDemo = PlotDemo()
        let plotPipeline = plotDemo.initPipeline(for: device)
        plotDemo.initBuffers(for: device)
        
        demoCache[.Triangle] = Runnable(pipeline: trianglePipeline, runner: triangleDemo)
        demoCache[.Quad] = Runnable(pipeline: flatQuadPipeline, runner: flatQuadDemo)
        demoCache[.Plot] = Runnable(pipeline: plotPipeline, runner: plotDemo)
    }
}
