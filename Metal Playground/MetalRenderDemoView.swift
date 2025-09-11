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
    var demo : MetalRenderDemo
    var queue : MTLCommandQueue
    var device: MTLDevice
    init(demo selected: Binding<Demo>) {
        device = MTLCreateSystemDefaultDevice()!
        queue = device.makeCommandQueue()!
        demo = try! MetalRenderDemo(for: device, with: queue)
        _selectedDemo = selected
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
    
    func updateNSView(_ mtkView: MTKView, context: Context) {}
    
}
