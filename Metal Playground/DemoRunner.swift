//
//  DemoRunner.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-10.
//


import SwiftUI
import simd
import MetalKit

protocol DemoRunner {
    // before rendering, a caller will set the state to this pipelinestate
    // Returns nil for demos that manage their own pipeline states
    func initPipeline(for device: MTLDevice) -> MTLRenderPipelineState?
    mutating func initBuffers(for device: MTLDevice)
    func draw(with encoder: MTLRenderCommandEncoder)
    var clearColor: MTLClearColor { get }

    // API for self-managed pipeline states
    var managesOwnPipelineStates: Bool { get }
    func drawWithPipelineManagement(with encoder: MTLRenderCommandEncoder, device: MTLDevice)
}

// Default implementations for existing demos
extension DemoRunner {
    var managesOwnPipelineStates: Bool { false }

    func drawWithPipelineManagement(with encoder: MTLRenderCommandEncoder, device: MTLDevice) {
        // Default implementation delegates to regular draw method
        draw(with: encoder)
    }
}
