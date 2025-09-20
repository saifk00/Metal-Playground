//
//  PlotDSL.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import simd
import Metal

@resultBuilder
struct PlotBuilder {
    static func buildBlock(_ elements: any DrawableNode...) -> [any DrawableNode] {
        return elements
    }

    static func buildArray(_ elements: [any DrawableNode]) -> [any DrawableNode] {
        return elements
    }

    static func buildOptional(_ element: (any DrawableNode)?) -> [any DrawableNode] {
        return element.map { [$0] } ?? []
    }

    static func buildEither(first element: any DrawableNode) -> [any DrawableNode] {
        return [element]
    }

    static func buildEither(second element: any DrawableNode) -> [any DrawableNode] {
        return [element]
    }
}

class Plot {
    let elements: [any DrawableNode]

    // Scene rendering system
    private lazy var sceneRenderer: SceneRenderer = {
        SceneRenderer(drawables: elements)
    }()

    init(@PlotBuilder content: () -> [any DrawableNode]) {
        self.elements = content()
    }

    // Rendering API that delegates to SceneRenderer
    func setupPipeline(device: MTLDevice) throws {
        try sceneRenderer.initPipeline(for: device)
    }

    func setupBuffers(device: MTLDevice) throws {
        try sceneRenderer.initBuffers(for: device)
    }

    func render(with encoder: MTLRenderCommandEncoder) {
        sceneRenderer.draw(with: encoder)
    }
    
    func generateAllVertices() -> [PlotDSLVertex] {
        return elements.flatMap { $0.generateUnifiedVertices() }
    }
    
    func totalVertexCount() -> Int {
        return elements.reduce(0) { $0 + $1.vertexCount() }
    }
}
