//
//  Drawable.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation

// TODO deprecate DrawableNode in favor of AbstractDrawableNode
protocol DrawableNode : AbstractDrawableNode {
    associatedtype VertexType: CustomVertexStruct
    func generateVertices() -> [VertexType]
    func vertexCount() -> Int
    func generateUnifiedVertices() -> [PlotDSLVertex]  // Type erasure method
}
