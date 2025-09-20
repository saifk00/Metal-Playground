# High Level Design
This project contains several demos, the only interesting one of which is the SceneBasedPlot. The goal is to use Swift's resultBuilder system to
have a DSL that lets you build a scene of basic 3D objects. The compiler then takes this scene description, performs various optimizations on it,
and decides how to render the scene using metal shaders. This allows you to define a scene with fairly simple syntax:

```swift
        // Create a sample plot using the DSL
        plot = Plot {
            // A plane in 3D space
            Plane(normal: Vector3D(1, 1, 1), offset: Vector3D(0.1, 0.1, 0.1), size: 1)
            
            // 3D Coordinate axes
            Line3D(from: Vector3D(-0.8, 0.0, 0.0), to: Vector3D(0.8, 0.0, 0.0))  // X-axis (red conceptually)
            Line3D(from: Vector3D(0.0, -0.8, 0.0), to: Vector3D(0.0, 0.8, 0.0))  // Y-axis (green conceptually)
            Line3D(from: Vector3D(0.0, 0.0, -0.8), to: Vector3D(0.0, 0.0, 0.8))  // Z-axis (blue conceptually)
        }
``` 

## PlotDSL
PlotDSL.swift contains the definition of the resultBuilder. The root node of the DSL's syntax is the AbstractDrawableNode; 
the compiler takes a tree of AbstractDrawableNodes and successively lowers it until we have a full description of how to
render the scene using Metal. 

## Compiler
The goal of the compiler is to successively update the state of AbstractDrawableNodes until they are ready to be rendered as a `CompiledScene`. To ensure separation
of concerns, the compiler is broken up into a series of 'stages' implemented as visitors on the AbstractDrawableNodes graph.

There are two steps to generating GPU-ready geometries. The first is to decide, for the graph of AbstractDrawables,
what shader each one will use. we can then group all the objects that use the same set of shaders into "render groups" since they will
share the same vertex format, and can thus be coalesced into a single vertex buffer. This is done in `RenderGroupAssignmentVisitor`

The second step is to actually generate the vertices. The visitor `VertexGenerationVisitor` knows how to generate the vertices of certain primitive geometries;
the idea is that if you want to introduce a complex geometry, you needn't reimplement the vertex generation if you can create a visitor that turns that node into
a subgraph of abstractDrawables.

## MetalSceneRenderer
MetalSceneRenderer takes the CompiledScene and actually renders it. It simply goes through the render groups, sets the vertex buffer, pipeline state etc., then invokes each draw command by translating it into a encoder.drawPrimitives call
