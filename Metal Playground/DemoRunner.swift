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
    func initPipeline(for device: MTLDevice) -> MTLRenderPipelineState
    mutating func initBuffers(for device: MTLDevice)
    func draw(with encoder: MTLRenderCommandEncoder)
}
