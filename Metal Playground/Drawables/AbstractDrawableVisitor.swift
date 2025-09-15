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

    func visitSelf(_ plane: Plane) -> Result?
    func visitSelf(_ planeNode: PlaneNode) -> Result?
    func visitSelf(_ line: Line3D) -> Result?
    func visitSelf(_ line: Line2D) -> Result?
    func visit(_ node: any AbstractDrawableNode) -> Result?
}

// default implementation - children first
extension AbstractDrawableVisitor {
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
    
    func visit(_ node: any AbstractDrawableNode) -> Result? {
        _ = node.children.map { visit($0) }
        let selfResult = node.accept(self)
        return selfResult
    }
}
