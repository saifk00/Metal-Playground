//
//  PipelineSelector.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-20.
//

import Foundation

/// Component responsible for selecting the appropriate pipeline descriptor
/// for a given AbstractDrawableNode concrete type.
struct PipelineSelector {

    /// Selects the appropriate pipeline descriptor for the given node type.
    /// This method encapsulates all pipeline selection logic in one place.
    static func selectPipeline(for node: any AbstractDrawableNode) -> DrawablePipelineDescriptor {
        switch node {
        case is Plane:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        case is PlaneNode:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        case is Line3D, is Line2D:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        case is Sphere, is Cone:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        case is SceneRootNode:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        default:
            // Fallback pipeline for unknown node types
            return DrawablePipelineDescriptor(
                vertexFunction: "default_vertex",
                fragmentFunction: "default_fragment"
            )
        }
    }

    /// Alternative method that uses type information directly.
    /// Useful when you have the concrete type available.
    static func selectPipeline<T: AbstractDrawableNode>(for nodeType: T.Type) -> DrawablePipelineDescriptor {
        switch nodeType {
        case is Plane.Type:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        case is PlaneNode.Type:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        case is Line3D.Type, is Line2D.Type:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        case is Sphere.Type, is Cone.Type:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        case is SceneRootNode.Type:
            return DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            )

        default:
            return DrawablePipelineDescriptor(
                vertexFunction: "default_vertex",
                fragmentFunction: "default_fragment"
            )
        }
    }
}

// MARK: - Pipeline Selection Rules

extension PipelineSelector {

    /// Returns all unique pipeline descriptors that this selector can produce.
    /// Useful for pre-allocating pipeline states or validation.
    static var allPipelineDescriptors: [DrawablePipelineDescriptor] {
        return [
            DrawablePipelineDescriptor(
                vertexFunction: "plot_vertex_shader",
                fragmentFunction: "plot_fragment_shader"
            ),
            DrawablePipelineDescriptor(
                vertexFunction: "default_vertex",
                fragmentFunction: "default_fragment"
            )
        ]
    }

    /// Predefined pipeline descriptors for common use cases
    enum PredefinedPipelines {
        static let plotPipeline = DrawablePipelineDescriptor(
            vertexFunction: "plot_vertex_shader",
            fragmentFunction: "plot_fragment_shader"
        )

        static let defaultPipeline = DrawablePipelineDescriptor(
            vertexFunction: "default_vertex",
            fragmentFunction: "default_fragment"
        )
    }
}