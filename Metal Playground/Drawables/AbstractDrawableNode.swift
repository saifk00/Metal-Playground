//
//  AbstractDrawableNode.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-09-13.
//

protocol AbstractDrawableNode {
    var children: [any AbstractDrawableNode] { get }

    func accept<V: AbstractDrawableVisitor>(_ visitor: V) -> V.Result
}
