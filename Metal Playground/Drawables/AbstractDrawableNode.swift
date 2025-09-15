//
//  AbstractDrawableNode.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-13.
//

import simd

protocol AbstractDrawableNode: AnyObject {
    var children: [any AbstractDrawableNode] { get }

    func accept<V: AbstractDrawableVisitor>(_ visitor: V) -> V.Result?

    // Composable transform API
    func applyTransform(_ transform: simd_float4x4)
    func getWorldTransform() -> simd_float4x4
}
