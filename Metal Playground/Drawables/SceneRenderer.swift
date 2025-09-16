//
//  SceneRenderer.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Metal

class SceneRenderer {
    private let rootNode: SceneRootNode
    private let compiler: DrawableCompiler
    private let metalRenderer: MetalSceneRenderer

    // Lazy compilation - only happens when first accessed
    private lazy var compiledScene: CompiledScene = {
        return compiler.compile(rootNode)
    }()

    init(drawables: [any DrawableNode]) {
        self.rootNode = SceneRootNode(children: drawables)
        self.compiler = DrawableCompiler()
        self.metalRenderer = MetalSceneRenderer()
    }

    func initPipeline(for device: MTLDevice) throws {
        // Scene compiles automatically on first access
        try metalRenderer.initPipeline(from: compiledScene, device: device)
    }

    func initBuffers(for device: MTLDevice) throws {
        var scene = compiledScene  // Lazy compilation happens here

        // Generate GPU buffers and draw commands
        try metalRenderer.initBuffers(from: &scene)

        // Update the lazy property with buffer information
        compiledScene = scene
    }

    func draw(with encoder: MTLRenderCommandEncoder) {
        metalRenderer.draw(scene: compiledScene, with: encoder)
    }

    // For debugging and inspection
    func getCompiledScene() -> CompiledScene {
        return compiledScene  // No longer optional
    }

    func getRootNode() -> SceneRootNode {
        return rootNode
    }

    // Force recompilation (useful when scene graph changes)
    func invalidateCache() {
        compiledScene = compiler.compile(rootNode)
    }
}

enum SceneRendererError: Error {
    case compilationFailed
    case sceneNotCompiled
}
