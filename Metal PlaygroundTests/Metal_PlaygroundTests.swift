//
//  Metal_PlaygroundTests.swift
//  Metal PlaygroundTests
//
//  Created by Saif Khattak on 2025-08-31.
//

import Testing
@testable import Metal_Playground

struct Metal_PlaygroundTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

}

struct DrawableCollectorVisitorTests {

    @Test func testSingleNodeCollection() async throws {
        // Test collecting a single node
        let line = Line2D(from: Point(0, 0), to: Point(1, 1))

        let collected = DrawableCollectorVisitor.collectDrawables(from: line)

        #expect(collected.count == 1)
        #expect(collected[0] is Line2D)
    }

    @Test func testPostOrderTraversal() async throws {
        // Create a simple tree structure with SceneRootNode and multiple children
        //     root
        //    /    \
        //  child1  child2

        let child1 = Line2D(from: Point(0, 0), to: Point(1, 1))
        let child2 = Line3D(from: Vector3D(0, 0, 0), to: Vector3D(1, 1, 1))
        let root = SceneRootNode(children: [child1, child2])

        let collected = DrawableCollectorVisitor.collectDrawables(from: root)

        // Post-order traversal should visit: child1, child2, root
        #expect(collected.count == 3)
        #expect(collected[0] is Line2D)        // child1
        #expect(collected[1] is Line3D)        // child2
        #expect(collected[2] is SceneRootNode) // root
    }

    @Test func testEmptySceneRoot() async throws {
        // Test with a SceneRootNode that has no children
        let emptyRoot = SceneRootNode(children: [])

        let collected = DrawableCollectorVisitor.collectDrawables(from: emptyRoot)

        #expect(collected.count == 1)
        #expect(collected[0] is SceneRootNode)
    }

    @Test func testMultipleChildrenOrder() async throws {
        // Test that post-order visits children in the correct order
        let plane = Plane(normal: Vector3D(0, 0, 1), offset: Vector3D(0, 0, 0))
        let line2d = Line2D(from: Point(0, 0), to: Point(1, 1))
        let line3d = Line3D(from: Vector3D(0, 0, 0), to: Vector3D(1, 1, 1))
        let root = SceneRootNode(children: [plane, line2d, line3d])

        let collected = DrawableCollectorVisitor.collectDrawables(from: root)

        // Post-order should visit: plane, line2d, line3d, root (children first, then parent)
        #expect(collected.count == 4)
        #expect(collected[0] is Plane)         // plane (first child)
        #expect(collected[1] is Line2D)        // line2d (second child)
        #expect(collected[2] is Line3D)        // line3d (third child)
        #expect(collected[3] is SceneRootNode) // root (parent last)
    }
}
