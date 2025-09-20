//
//  DrawableCollectorVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation

// visitor that collects all the nodes in the scene as a pre-ordered list
class DrawableCollectorVisitor: BaseDrawableVisitor<[any AbstractDrawableNode]> {
    typealias Result = [any AbstractDrawableNode]

    private var collectedNodes: [any AbstractDrawableNode] = []

    override func visitSelf(_ node: any AbstractDrawableNode) -> [any AbstractDrawableNode]? {
        collectedNodes.append(node)
        return nil
    }

    func getCollectedNodes() -> [any AbstractDrawableNode] {
        return collectedNodes
    }

    static func collectDrawables(from node: any AbstractDrawableNode) -> [any AbstractDrawableNode] {
        let collector = DrawableCollectorVisitor()
        let _ = collector.visit(node)
        return collector.getCollectedNodes()
    }
}
