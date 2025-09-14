//
//  Line2D.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd

struct Line2D: DrawableNode, AbstractDrawableNode {
    typealias VertexType = PlotDSLVertex
    
    let from: Point
    let to: Point
    
    func generateVertices() -> [PlotDSLVertex] {
        return [
            PlotDSLVertex(SIMD3(from.x, from.y, 0.0)),
            PlotDSLVertex(SIMD3(to.x, to.y, 0.0))
        ]
    }
    
    func generateUnifiedVertices() -> [PlotDSLVertex] {
        return generateVertices()
    }
    
    func vertexCount() -> Int { return 2 }

    var children: [any AbstractDrawableNode] { return [] }

    func accept<V: AbstractDrawableVisitor>(_ visitor: V) -> V.Result {
        return visitor.visitSelf(self)
    }

    func isEqual(to other: Line2D) -> Bool {
        return self.from == other.from && self.to == other.to
    }
}
