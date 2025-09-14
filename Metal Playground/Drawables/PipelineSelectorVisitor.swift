//
//  PipelineSelectorVisitor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import simd

struct PipelinedDrawable {
    let placedDrawable: PlacedDrawable
    let pipelineDescriptor: DrawablePipelineDescriptor
}

struct PipelineSelectorVisitor: AbstractDrawableVisitor {
    typealias Result = [PipelinedDrawable]

    let pipelineLibrary: DrawablePipelineLibrary

    func visitSelf(_ plane: Plane) -> [PipelinedDrawable] {
        guard let pipeline = pipelineLibrary.getPipeline(for: plane) else {
            return []
        }
        let placedDrawable = PlacedDrawable(plane)
        return [PipelinedDrawable(placedDrawable: placedDrawable, pipelineDescriptor: pipeline)]
    }

    func visitSelf(_ line: Line3D) -> [PipelinedDrawable] {
        guard let pipeline = pipelineLibrary.getPipeline(for: line) else {
            return []
        }
        let placedDrawable = PlacedDrawable(line)
        return [PipelinedDrawable(placedDrawable: placedDrawable, pipelineDescriptor: pipeline)]
    }

    func visitSelf(_ line: Line2D) -> [PipelinedDrawable] {
        guard let pipeline = pipelineLibrary.getPipeline(for: line) else {
            return []
        }
        let placedDrawable = PlacedDrawable(line)
        return [PipelinedDrawable(placedDrawable: placedDrawable, pipelineDescriptor: pipeline)]
    }

    func visitSelf(_ plot: Plot) -> [PipelinedDrawable] {
        // Plot itself doesn't generate pipeline assignments, only its children do
        return []
    }

    func combine(_ results: [Result]) -> Result {
        return results.flatMap { $0 }
    }
}
