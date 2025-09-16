//
//  DrawablePipelineDescriptor.swift
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

import Foundation

struct DrawablePipelineDescriptor: Hashable {
    let vertexFunction: String
    let fragmentFunction: String

    init(vertexFunction: String, fragmentFunction: String) {
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
    }
}