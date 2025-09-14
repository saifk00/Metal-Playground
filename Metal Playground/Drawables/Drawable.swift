//
//  Drawable.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation

protocol Drawable {
    associatedtype VertexType: CustomVertexStruct
    func generateVertices() -> [VertexType]
    func vertexCount() -> Int
    func generateUnifiedVertices() -> [PlotDSLVertex]  // Type erasure method
}
