//
//  Plane.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd

struct Plane: DrawableNode, AbstractDrawableNode {
    typealias VertexType = PlotDSLVertex
    
    let n: SIMD3<Float>
    let offset: SIMD3<Float>
    let size: Float  // Side length of plane square
    
    init(normal: Vector3D, offset: Vector3D, size: Float = 1.0) {
        self.n = normalize(normal.simd)
        self.offset = SIMD3<Float>(offset)
        self.size = size
    }
    
    func generateVertices() -> [PlotDSLVertex] {
        // Find two orthogonal vectors to the normal
        var u: SIMD3<Float>
        if abs(n.x) < 0.9 {
            u = normalize(cross(n, SIMD3<Float>(1, 0, 0)))
        } else {
            u = normalize(cross(n, SIMD3<Float>(0, 1, 0)))
        }
        let v = cross(n, u)
        
        // Create plane vertices centered at offset
        let halfSize = size * 0.5
        
        let corners: [SIMD3<Float>] = [
            offset + halfSize * (-u - v),  // Bottom-left
            offset + halfSize * (u - v),   // Bottom-right
            offset + halfSize * (u + v),   // Top-right
            offset + halfSize * (-u + v)   // Top-left
        ]
        
        // Generate triangles for the plane (two triangles make a quad)
        let blueColor = SIMD4<Float>(0, 0, 1, 1)  // Solid blue
        return [
            // First triangle: bottom-left, bottom-right, top-left
            PlotDSLVertex(corners[0], color: blueColor),
            PlotDSLVertex(corners[1], color: blueColor),
            PlotDSLVertex(corners[3], color: blueColor),
            // Second triangle: bottom-right, top-right, top-left  
            PlotDSLVertex(corners[1], color: blueColor),
            PlotDSLVertex(corners[2], color: blueColor),
            PlotDSLVertex(corners[3], color: blueColor)
        ]
    }
    
    func generateUnifiedVertices() -> [PlotDSLVertex] {
        return generateVertices()
    }
    
    func vertexCount() -> Int { return 6 }  // 2 triangles = 6 vertices

    var children: [any AbstractDrawableNode] { return [] }

    func accept<V: AbstractDrawableVisitor>(_ visitor: V) -> V.Result {
        return visitor.visitSelf(self)
    }

    func isEqual(to other: Plane) -> Bool {
        return simd_equal(self.n, other.n) &&
               simd_equal(self.offset, other.offset) &&
               self.size == other.size
    }
}
