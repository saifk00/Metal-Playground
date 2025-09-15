# Progressive Interface Design for Rendering Pipeline

## Problem Statement

The original hierarchical drawable design used a "compiler pass pipeline" approach where each stage created wrapper types around nodes (`AbstractDrawableNode` → `PlacedDrawable` → `PipelinedDrawGroup`). This created several issues:

1. **Type proliferation**: Every stage required new wrapper types, leading to complex nested structures
2. **Data redundancy**: Each wrapper contained the previous stage's wrapper, creating memory overhead
3. **Complexity scaling**: Adding new stages meant introducing new wrapper types at every level

**Key insight**: We shouldn't have to introduce a new node type every time we want to add a stage that adds information to a node before it's ready for the next stage.

## Solution: Progressive Interfaces

Instead of creating wrapper types, we use **progressive interfaces** that represent nodes at different stages of compilation. The same node object flows through the pipeline, getting progressively enriched with data from each stage.

## Architecture

### Core Concept: Single Node, Multiple Interfaces

```swift
// Single node class with core data
class PlaneNode: AbstractDrawableNode {
    let width: Float  // Immutable core data
    let height: Float
    // ... stage-specific data added via extensions
}

// Progressive interfaces represent compilation stages
protocol AbstractDrawableNode { /* base */ }
protocol TransformedDrawableNode: AbstractDrawableNode { var worldTransform: SIMD4x4<Float>? }
protocol PipelinedDrawableNode: TransformedDrawableNode { var pipelineDescriptor: DrawablePipelineDescriptor? }
protocol BufferedDrawableNode: PipelinedDrawableNode { var vertexRange: (offset: Int, count: Int)? }
```

### Stage-Specific Storage Pattern

**Problem**: How do we add stage-specific properties without polluting the main class?

**Solution**: Separate storage protocols with `@AssociatedStorage` property wrapper:

```swift
// Clean storage separation
protocol TransformStorage {
    var worldTransform: SIMD4x4<Float>? { get set }
}

extension PlaneNode: TransformStorage {
    @AssociatedStorage var worldTransform: SIMD4x4<Float>?  // No class pollution
}
```

The `@AssociatedStorage` wrapper uses Objective-C runtime's `objc_getAssociatedObject` to attach data to existing objects without modifying their class definition.

## Key Design Considerations

### 1. Multiple Transform Passes
**Challenge**: There might be multiple passes that act like transform visitors (fixed offset, parent-child offsets, animation, etc.).

**Solution**: All transform visitors work with the same `TransformStorage` interface and chain transforms:

```swift
struct RotationVisitor {
    func visitSelf(_ node: PlaneNode) {
        let rotation = computeRotation()
        node.worldTransform = (node.worldTransform ?? .identity) * rotation  // Chain transforms
    }
}
```

### 2. Stage Ordering Enforcement
**Challenge**: How do we ensure all necessary transform visitors run before pipeline selection?

**Solution**: Keep it simple with testing and pipeline coordinators. The type system enforces stage boundaries:

```swift
struct PipelineSelector {
    func process(_ node: any TransformedDrawableNode) {  // Type system enforces transform stage completed
        // Can safely access worldTransform
        node.pipelineDescriptor = selectPipeline(node.worldTransform)
    }
}
```

### 3. Clean Data Separation
**Challenge**: How do we differentiate between properties that each stage is responsible for without polluting the main class?

**Solution**: Stage-specific storage protocols keep concerns separated:

```swift
// Each stage owns its data via protocols + extensions
protocol TransformStorage { var worldTransform: SIMD4x4<Float>? }
protocol PipelineStorage { var pipelineDescriptor: DrawablePipelineDescriptor? }
protocol BufferStorage { var vertexRange: (offset: Int, count: Int)? }
```

## Benefits

1. **No Type Proliferation**: Single node type throughout the entire pipeline
2. **Memory Efficient**: No wrapper nesting, data attached directly to nodes
3. **Type Safety**: Progressive interfaces enforce proper stage ordering
4. **Clean Separation**: Stage-specific storage keeps concerns isolated
5. **Extensible**: Easy to add new stages without modifying existing code
6. **Transform Chaining**: Multiple transform passes compose naturally

## Implementation Pattern

```swift
// 1. Create node
let plane = PlaneNode(width: 2.0, height: 2.0)

// 2. Apply progressive transformations
let rotationVisitor = RotationTransformVisitor(angle: .pi/4, axis: [0,0,1])
let transformed: any TransformedDrawableNode = plane.accept(rotationVisitor)

// 3. Pipeline selection (type system ensures transform completed)
let pipelined: any PipelinedDrawableNode = pipelineSelector.process(transformed)

// 4. Same object, progressively enriched
assert(plane === pipelined)  // Same object reference!
```

## Key Innovation

The fundamental insight is treating compilation stages as **progressive enrichment** of the same object rather than **wrapping** it in new types. This eliminates complexity while maintaining type safety and clean separation of concerns.