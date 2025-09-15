//
//  DrawableCollectorVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-15.
//

import Foundation

struct DrawableCollectorVisitor: AbstractDrawableVisitor {
    typealias Result = [any AbstractDrawableNode]

    private var collectedNodes: [any AbstractDrawableNode] = []

    mutating func visitSelf(_ plane: Plane) -> [any AbstractDrawableNode]? {
        collectedNodes.append(plane)
        return nil
    }

    mutating func visitSelf(_ planeNode: PlaneNode) -> [any AbstractDrawableNode]? {
        collectedNodes.append(planeNode)
        return nil
    }

    mutating func visitSelf(_ line: Line3D) -> [any AbstractDrawableNode]? {
        collectedNodes.append(line)
        return nil
    }

    mutating func visitSelf(_ line: Line2D) -> [any AbstractDrawableNode]? {
        collectedNodes.append(line)
        return nil
    }

    // Override visit to collect children first, then self
    mutating func visit(_ node: any AbstractDrawableNode) -> [any AbstractDrawableNode]? {
        // Visit all children first
        for child in node.children {
            let _ = visit(child)
        }

        // Then visit self (which will add to collection if it's a drawable)
        let _ = node.accept(self)

        return collectedNodes
    }

    func getCollectedNodes() -> [any AbstractDrawableNode] {
        return collectedNodes
    }

    // Static convenience methods
    static func collectDrawables(from nodes: [any AbstractDrawableNode]) -> [any AbstractDrawableNode] {
        var collector = DrawableCollectorVisitor()
        for node in nodes {
            let _ = collector.visit(node)
        }
        return collector.getCollectedNodes()
    }

    static func collectDrawables(from node: any AbstractDrawableNode) -> [any AbstractDrawableNode] {
        var collector = DrawableCollectorVisitor()
        let _ = collector.visit(node)
        return collector.getCollectedNodes()
    }
}