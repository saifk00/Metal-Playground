//
//  TransformerVisitor.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-13.
//

import Foundation
import simd

struct TransformApplyingVisitor: AbstractDrawableVisitor {
    typealias Result = PlacedDrawable

    func visitSelf(_ plane: Plane) -> PlacedDrawable {
        return PlacedDrawable(plane)
    }

    func visitSelf(_ line: Line3D) -> PlacedDrawable {
        return PlacedDrawable(line)
    }

    func visitSelf(_ line: Line2D) -> PlacedDrawable {
        return PlacedDrawable(line)
    }

    func visitSelf(_ plot: Plot) -> PlacedDrawable {
        // Plot itself doesn't generate vertices, only its children do
        return PlacedDrawable(plot)
    }
}

struct PlacedDrawable: Equatable {
    let drawable: any AbstractDrawableNode
    let worldTransform: simd_float4x4?

    // a drawable that requires no transformation before
    // vertex generation
    init(_ drawable: any AbstractDrawableNode) {
        self.drawable = drawable
        self.worldTransform = nil
    }

    static func == (lhs: PlacedDrawable, rhs: PlacedDrawable) -> Bool {
        // Compare transforms first (simple comparison)
        if lhs.worldTransform != rhs.worldTransform {
            return false
        }

        // Compare drawable types and content
        return lhs.drawable.isEqual(to: rhs.drawable)
    }
}

// Extension to add equality checking to AbstractDrawableNode
extension AbstractDrawableNode {
    func isEqual(to other: any AbstractDrawableNode) -> Bool {
        // First check if they're the same type
        guard type(of: self) == type(of: other) else {
            return false
        }

        // Type-specific equality checking
        switch (self, other) {
        case let (plane1 as Plane, plane2 as Plane):
            return plane1.isEqual(to: plane2)
        case let (line1 as Line3D, line2 as Line3D):
            return line1.isEqual(to: line2)
        case let (line2d1 as Line2D, line2d2 as Line2D):
            return line2d1.isEqual(to: line2d2)
        case let (plot1 as Plot, plot2 as Plot):
            return plot1.isEqual(to: plot2)
        default:
            return false
        }
    }
}
