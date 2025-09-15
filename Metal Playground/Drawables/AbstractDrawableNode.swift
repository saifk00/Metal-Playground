//
//  AbstractDrawableNode.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-13.
//

import simd

enum VertexStorageError: Error {
    case verticesAlreadySet
    case verticesNotSet
}

protocol AbstractDrawableNode: AnyObject {
    var children: [any AbstractDrawableNode] { get }

    func accept<V: AbstractDrawableVisitor>(_ visitor: V) -> V.Result?

    // Composable transform API
    func applyTransform(_ transform: simd_float4x4)
    func getWorldTransform() -> simd_float4x4

    // Vertex storage API - single-set with safety constraints
    func setVertices(_ vertices: [PlotDSLVertex]) throws
    func getVertices() -> [PlotDSLVertex]?
    func hasVertices() -> Bool
    func applyVertexTransform(_ transform: simd_float4x4)
}
