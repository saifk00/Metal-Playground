//
//  MetalRenderDemoView.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-10.
//


import SwiftUI
import simd
import MetalKit

/**
 A NSView wrapper around a core {@link MetalRenderDemo}. the demo is a delegate for the underlying MTKView
 */
struct MetalRenderDemoView : NSViewRepresentable {
    @Binding var selectedDemo: Demo
    @State private var demo : MetalRenderDemo

    init(demo selected: Binding<Demo>) {
        _selectedDemo = selected
        
        // only initialize these once
        let device = MTLCreateSystemDefaultDevice()!
        let queue = device.makeCommandQueue()!
        demo = try! MetalRenderDemo(for: device, with: queue)
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()

        mtkView.device = demo.device
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
        demo.setCurrentDemo(selectedDemo)
    }
    
}
