//
//  TransformApplierVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation
import simd

class TransformApplierVisitor: BaseDrawableVisitor<Void> {
    typealias Result = Void

    override func visitSelf(_ node: any AbstractDrawableNode) -> Void? {
        let transform = node.getWorldTransform()
        node.applyVertexTransform(transform)
        return nil
    }

    static func applyTransforms(to node: any AbstractDrawableNode) {
        var applier = TransformApplierVisitor()
        let _ = node.accept(&applier)
    }
}
