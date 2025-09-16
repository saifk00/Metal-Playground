//
//  DrawableVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd

protocol AbstractDrawableVisitor {
    associatedtype Result

    // Node-specific visit methods - implement these for custom behavior
    mutating func visitSelf(_ plane: Plane) -> Result?
    mutating func visitSelf(_ planeNode: PlaneNode) -> Result?
    mutating func visitSelf(_ line: Line3D) -> Result?
    mutating func visitSelf(_ line: Line2D) -> Result?
    mutating func visitSelf(_ sceneRoot: SceneRootNode) -> Result?

    // Tree traversal method - use this for visiting entire trees
    mutating func visit(_ node: any AbstractDrawableNode) -> Result?
}

// Base class implementation for visitors
class BaseDrawableVisitor<Result>: AbstractDrawableVisitor {
    // Default no-op implementations for visitSelf methods
    func visitSelf(_ plane: Plane) -> Result? {
        return nil
    }
    func visitSelf(_ planeNode: PlaneNode) -> Result? {
        return nil
    }
    func visitSelf(_ line: Line3D) -> Result? {
        return nil
    }
    func visitSelf(_ line: Line2D) -> Result? {
        return nil
    }
    func visitSelf(_ sceneRoot: SceneRootNode) -> Result? {
        return nil
    }

    // Default tree traversal implementation - visits children first, then self
    // Use visitor.visit(node) for full tree traversal
    // Use node.accept(visitor) for single node visitation only
    func visit(_ node: any AbstractDrawableNode) -> Result? {
        for child in node.children {
            _ = visit(child)
        }
        var mutableSelf = self
        let selfResult = node.accept(&mutableSelf)
        return selfResult
    }
}

// Extension for protocol conformance with structs (for non-mutating visitors)
extension AbstractDrawableVisitor {
    // Default no-op implementations for visitSelf methods
    mutating func visitSelf(_ plane: Plane) -> Result? {
        return nil
    }
    mutating func visitSelf(_ planeNode: PlaneNode) -> Result? {
        return nil
    }
    mutating func visitSelf(_ line: Line3D) -> Result? {
        return nil
    }
    mutating func visitSelf(_ line: Line2D) -> Result? {
        return nil
    }
    mutating func visitSelf(_ sceneRoot: SceneRootNode) -> Result? {
        return nil
    }

    // Default tree traversal implementation - visits children first, then self
    // Use visitor.visit(node) for full tree traversal
    // Use node.accept(visitor) for single node visitation only
    mutating func visit(_ node: any AbstractDrawableNode) -> Result? {
        for child in node.children {
            _ = visit(child)
        }
        let selfResult = node.accept(&self)
        return selfResult
    }
}
