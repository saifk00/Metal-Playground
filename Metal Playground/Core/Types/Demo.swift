//
//  Demo.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-08-31.
//

import Foundation
import MetalKit

enum Demo: String, CaseIterable, Identifiable {
    var id: Demo { self }

    case Triangle
    case Quad
    case Plot
    case SceneBasedPlot
}

struct Runnable {
    let pipeline: MTLRenderPipelineState?
    let runner: DemoRunner
}