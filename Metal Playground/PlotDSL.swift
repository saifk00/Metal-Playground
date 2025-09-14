//
//  PlotDSL.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

@resultBuilder
struct PlotBuilder {
    static func buildBlock(_ elements: any DrawableNode...) -> [any DrawableNode] {
        return elements
    }

    static func buildArray(_ elements: [any DrawableNode]) -> [any DrawableNode] {
        return elements
    }

    static func buildOptional(_ element: (any DrawableNode)?) -> [any DrawableNode] {
        return element.map { [$0] } ?? []
    }

    static func buildEither(first element: any DrawableNode) -> [any DrawableNode] {
        return [element]
    }

    static func buildEither(second element: any DrawableNode) -> [any DrawableNode] {
        return [element]
    }
}

struct Plot: AbstractDrawableNode {
    let elements: [any DrawableNode]

    var children: [any AbstractDrawableNode] {
        // Convert DrawableNodes to AbstractDrawableNodes
        return elements.compactMap { $0 as? AbstractDrawableNode }
    }

    init(@PlotBuilder content: () -> [any DrawableNode]) {
        self.elements = content()
    }

    func accept<V: AbstractDrawableVisitor>(_ visitor: V) -> V.Result {
        return visitor.visitSelf(self)
    }
    
    func generateAllVertices() -> [PlotDSLVertex] {
        return elements.flatMap { $0.generateUnifiedVertices() }
    }
    
    func totalVertexCount() -> Int {
        return elements.reduce(0) { $0 + $1.vertexCount() }
    }

    func isEqual(to other: Plot) -> Bool {
        guard self.elements.count == other.elements.count else {
            return false
        }

        // Compare each element (this is a bit complex since elements are DrawableNodes)
        for (selfElement, otherElement) in zip(self.elements, other.elements) {
            // Cast both to AbstractDrawableNode for comparison
            guard let selfDrawable = selfElement as? AbstractDrawableNode,
                  let otherDrawable = otherElement as? AbstractDrawableNode else {
                return false
            }

            if !selfDrawable.isEqual(to: otherDrawable) {
                return false
            }
        }

        return true
    }
}
