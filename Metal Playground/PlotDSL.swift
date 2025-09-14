//
//  PlotDSL.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

@resultBuilder
struct PlotBuilder {
    static func buildBlock(_ elements: any Drawable...) -> [any Drawable] {
        return elements
    }
    
    static func buildArray(_ elements: [any Drawable]) -> [any Drawable] {
        return elements
    }
    
    static func buildOptional(_ element: (any Drawable)?) -> [any Drawable] {
        return element.map { [$0] } ?? []
    }
    
    static func buildEither(first element: any Drawable) -> [any Drawable] {
        return [element]
    }
    
    static func buildEither(second element: any Drawable) -> [any Drawable] {
        return [element]
    }
}

struct Plot {
    let elements: [any Drawable]
    
    init(@PlotBuilder content: () -> [any Drawable]) {
        self.elements = content()
    }
    
    func generateAllVertices() -> [PlotDSLVertex] {
        return elements.flatMap { $0.generateUnifiedVertices() }
    }
    
    func totalVertexCount() -> Int {
        return elements.reduce(0) { $0 + $1.vertexCount() }
    }
}
