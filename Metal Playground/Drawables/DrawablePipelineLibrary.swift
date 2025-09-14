//
//  DrawablePipelineLibrary.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation

class DrawablePipelineLibrary {
    private var pipelineMap: [ObjectIdentifier: DrawablePipelineDescriptor] = [:]

    init() {
        setupDefaultPipelines()
    }

    func setPipeline<T: AbstractDrawableNode>(for nodeType: T.Type, descriptor: DrawablePipelineDescriptor) {
        let typeId = ObjectIdentifier(nodeType)
        pipelineMap[typeId] = descriptor
    }

    func getPipeline(for node: any AbstractDrawableNode) -> DrawablePipelineDescriptor? {
        let typeId = ObjectIdentifier(type(of: node))
        return pipelineMap[typeId]
    }

    private func setupDefaultPipelines() {
        // Default pipeline for basic shapes
        let basicPipeline = DrawablePipelineDescriptor(
            vertexFunction: "basicVertexShader",
            fragmentFunction: "basicFragmentShader"
        )

        // Set up default mappings
        setPipeline(for: Plane.self, descriptor: basicPipeline)
        setPipeline(for: Line3D.self, descriptor: basicPipeline)
        setPipeline(for: Line2D.self, descriptor: basicPipeline)
    }
}