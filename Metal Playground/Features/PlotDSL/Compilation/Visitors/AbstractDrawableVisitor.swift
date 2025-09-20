//
//  DrawableVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation
import simd

// a visitor for AbstractDrawableNodes
protocol AbstractDrawableVisitor {
    associatedtype Result
    mutating func visitSelf(_ obj: AbstractDrawableNode) -> Result?

    // Node-specific visit methods - implement these for custom behavior
    mutating func visitSelf(_ plane: Plane) -> Result?
    mutating func visitSelf(_ planeNode: PlaneNode) -> Result?
    mutating func visitSelf(_ line: Line3D) -> Result?
    mutating func visitSelf(_ line: Line2D) -> Result?
    mutating func visitSelf(_ sphere: Sphere) -> Result?
    mutating func visitSelf(_ cone: Cone) -> Result?
    mutating func visitSelf(_ cylinder: Cylinder) -> Result?
    mutating func visitSelf(_ vectorArrow: VectorArrow) -> Result?
    mutating func visitSelf(_ sceneRoot: SceneRootNode) -> Result?

    // Tree traversal method - use this for visiting entire trees
    mutating func visit(_ node: any AbstractDrawableNode) -> Result?
}

// Base class implementation for visitors
// the default implementation is to visit yourself as your base class
class BaseDrawableVisitor<Result>: AbstractDrawableVisitor {
    func visitSelf(_ obj: AbstractDrawableNode) -> Result? {
        return nil
    }
    
    func visitSelf(_ plane: Plane) -> Result? {
        return visitSelf(plane as AbstractDrawableNode)
    }
    func visitSelf(_ planeNode: PlaneNode) -> Result? {
        return visitSelf(planeNode as AbstractDrawableNode)
    }
    func visitSelf(_ line: Line3D) -> Result? {
        return visitSelf(line as AbstractDrawableNode)
    }
    func visitSelf(_ line: Line2D) -> Result? {
        return visitSelf(line as AbstractDrawableNode)
    }
    func visitSelf(_ sphere: Sphere) -> Result? {
        return visitSelf(sphere as AbstractDrawableNode)
    }
    func visitSelf(_ cone: Cone) -> Result? {
        return visitSelf(cone as AbstractDrawableNode)
    }
    func visitSelf(_ cylinder: Cylinder) -> Result? {
        return visitSelf(cylinder as AbstractDrawableNode)
    }
    func visitSelf(_ vectorArrow: VectorArrow) -> Result? {
        return visitSelf(vectorArrow as AbstractDrawableNode)
    }
    func visitSelf(_ sceneRoot: SceneRootNode) -> Result? {
        return visitSelf(sceneRoot as AbstractDrawableNode)
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
