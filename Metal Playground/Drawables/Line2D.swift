//
//  Line2D.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd

struct Line2D: Drawable {
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
}