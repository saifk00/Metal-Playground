# Hierarchical Drawable System Design

## Overview

This design document outlines a multi-phase compilation system for transforming abstract drawable descriptions into optimized Metal rendering commands. The system supports hierarchical scene graphs with automatic layout, pipeline-aware vertex generation, and efficient GPU resource management.

## Core Philosophy

The system follows a compilation pipeline metaphor: `AbstractDrawable` → `PlacedDrawable` → `PipelinedDrawGroup` → `DrawCommands`. Each phase is pure and immutable, enabling type safety, caching, and parallel processing.

## Phase 1: Transform Application

**Input**: Tree of `AbstractDrawableNode` objects  
**Output**: Flattened list of `PlacedDrawable` objects  
**Purpose**: Apply hierarchical transformations and layout logic

### Example Scene Description
```swift
ObjectRow(axis: .x, spread: 10.0) {
    Sphere(radius: 1.0)  // positioned at x=-5.0
    Sphere(radius: 2.0)  // positioned at x=0.0  
    Sphere(radius: 1.5)  // positioned at x=+5.0
}
```

### Transformation Types
- **Layout Nodes**: `ObjectRow`, `ObjectGrid`, `ObjectCircle` - arrange children spatially
	- Analogy - HStack, VStack
- **Time transforms**: Animated { t -> doStuff }
	- Idea: we could create a separate time Uniform buffer when we try to render and pass it to the pipeline
- **Leaf Nodes**: `Sphere`, `Cube`, `Plane` - generate actual geometry

### Process
1. Traverse scene tree depth-first
2. Layout nodes compute transform matrices for each child
3. Accumulate transforms down the hierarchy  
4. Leaf nodes receive final world transforms
5. Output flattened list of positioned geometry

## Phase 2: Pipeline Selection

**Input**: List of `PlacedDrawable` objects  
**Output**: Multiple `PipelinedDrawGroup` objects  
**Purpose**: Group drawables by compatible pipeline requirements

### Process
1. Each `PlacedDrawable` declares its pipeline requirements
2. Group drawables with compatible vertex formats and shaders
3. Create separate `PipelinedDrawGroup` for each unique pipeline requirement
4. Hierarchical relationships are no longer needed

### Pipeline Requirements
- Vertex format (position + color, position + normal + UV, etc.)
- Shader program (basic, lit, textured, etc.)
- Blend states, depth testing requirements

## Phase 3: Vertex Generation & GPU Resource Allocation

**Input**: `PipelinedDrawGroup` objects  
**Output**: GPU buffers and draw command metadata  
**Purpose**: Generate pipeline-specific vertices and allocate GPU resources

### Process
1. For each `PipelinedDrawGroup`:
   - Ask each `PlacedDrawable` to generate vertices for the group's pipeline
   - Concatenate all vertices into a single buffer
   - Track vertex ranges for each drawable: `(offset: Int, count: Int)`
   - Allocate GPU buffer for the vertex data

### Key Insight
Vertices are generated with respect to a specific pipeline state. The same sphere might generate different vertex data for a basic color pipeline vs. a lighting pipeline with normals.

## Phase 4: Render Command Generation

**Input**: GPU buffers and vertex range metadata  
**Output**: List of `PipelinedDrawGroupCommand` objects  
**Purpose**: Generate Metal encoder commands without directly calling encoder

### Command Structure
```swift
struct PipelinedDrawGroupCommand {
    let primitiveType: MTLPrimitiveType
    let vertexStart: Int
    let vertexCount: Int
}
```

### Process
1. For each `PipelinedDrawGroup`, generate list of draw commands
2. Each `PlacedDrawable` contributes one or more commands based on its geometry
3. Commands are primitive type + vertex range pairs

## Phase 5: Encoder Execution (Per Frame)

**Input**: `PipelinedDrawGroup` objects and their commands  
**Output**: Rendered frame  
**Purpose**: Execute optimized draw calls

### Per-Frame Process
```swift
for group in pipelinedDrawGroups {
    encoder.setRenderPipelineState(group.pipelineState)
    encoder.setVertexBuffer(group.vertexBuffer, offset: 0, index: 0)
    
    for command in group.commands {
        encoder.drawPrimitives(
            type: command.primitiveType,
            vertexStart: command.vertexStart, 
            vertexCount: command.vertexCount
        )
    }
}
```

## Benefits

1. **Performance**: Minimal state changes, optimized draw calls, GPU resource reuse
2. **Type Safety**: Compiler prevents using uninitialized pipeline states or missing vertices
3. **Extensibility**: Easy to add new transformation types and pipeline requirements  
4. **Debuggability**: Can inspect pipeline state at any phase
5. **Caching**: Immutable phases enable intelligent caching strategies
6. **Parallel Processing**: Pure transformations can be parallelized safely

## Future Optimizations

- **Resource Caching**: Cache buffers for static scenes across frames
- **Incremental Updates**: Only rebuild changed portions of the scene graph
- **Indexed Drawing**: Extend commands to support indexed primitives
- **Instance Rendering**: Batch identical geometry with different transforms
- **Culling Integration**: Add frustum/occlusion culling between phases
- **Level of Detail**: Pipeline selection can choose appropriate LOD based on distance

## Implementation Notes

- Each phase produces immutable data structures
- Visitors implement phase transitions as pure functions  
- Error handling occurs at phase boundaries with fallback strategies
- Memory management uses RAII with automatic resource cleanup
