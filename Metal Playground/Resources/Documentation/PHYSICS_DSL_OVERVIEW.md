# Physics Visualization DSL - Design Overview

## Vision
A declarative Swift DSL for describing and visualizing physics problems through interactive 3D graphics. The system allows physicists and students to express complex physical phenomena (electromagnetic fields, gravitational systems, oscillators, etc.) in natural language-like syntax that compiles to efficient Metal rendering.

## Current Architecture

### High-Level Flow
```
Physics Concepts → AbstractDrawables → RenderGroups → Metal Shaders → GPU
```

### Core Components

#### 1. Declarative Scene Description
```swift
Plot {
    // Basic geometric primitives
    Plane(normal: Vector3D(1, 1, 1), offset: Vector3D(0.1, 0.1, 0.1), size: 1)
    Line3D(from: Vector3D(-0.8, 0.0, 0.0), to: Vector3D(0.8, 0.0, 0.0))

    // Future: Physics concepts
    // ElectricField(charges: [PointCharge(position: origin, charge: 1.0)])
    // GravityField(masses: [PointMass(position: origin, mass: 1.0)])
}
```

#### 2. AbstractDrawable System
- **Base Protocol**: `AbstractDrawable` defines high-level physics/geometric concepts
- **Node Tree**: Hierarchical scene representation with transforms
- **Visitor Pattern**: Separates concerns (grouping, vertex generation, transforms)

#### 3. Render Compilation Pipeline
1. **Scene Building**: DSL creates tree of `AbstractDrawableNode`s
2. **Group Assignment**: `RenderGroupAssignmentVisitor` batches by shader type
3. **Vertex Generation**: `VertexGeneratorVisitor` creates GPU-ready geometry
4. **Transform Application**: `TransformApplierVisitor` applies world transforms
5. **Buffer Creation**: Pack vertices into Metal buffers per group
6. **Rendering**: Metal draws with proper depth testing

#### 4. Metal Rendering Backend
- **Depth Testing**: Proper 3D occlusion between render groups
- **Pipeline States**: Cached, reusable shaders per drawable type
- **Efficient Batching**: Minimize draw calls while preserving depth accuracy

## Current Capabilities

### Primitives Available
- **Line3D**: 3D line segments (axes, trajectories, field lines)
- **Plane**: 3D planes (boundaries, surfaces, equipotentials)
- **Plot**: Container for composing scenes

### Rendering Features
- ✅ Proper 3D depth testing between different drawable types
- ✅ Efficient GPU batching by shader type
- ✅ Clean separation between physics concepts and rendering
- ✅ Real-time 60fps rendering via Metal

## Future Physics Concepts

### Electromagnetic Fields
```swift
Plot {
    // Point charges create electric field lines
    ElectricField(charges: [
        PointCharge(position: Vector3D(-1, 0, 0), charge: 1.0),
        PointCharge(position: Vector3D(1, 0, 0), charge: -1.0)
    ])

    // Equipotential surfaces
    EquipotentialSurface(potential: 0.5)
}
```

### Mechanical Systems
```swift
Plot {
    // Oscillating mass on spring
    Oscillator(mass: 1.0, springConstant: 10.0, amplitude: 2.0)

    // Trajectory visualization
    Trajectory(system: oscillator, timeRange: 0...10)

    // Phase space plot
    PhaseSpace(position: oscillator.x, momentum: oscillator.p)
}
```

### Gravitational Systems
```swift
Plot {
    // Central force problem
    GravityField(masses: [
        CentralMass(position: origin, mass: 1.0)
    ])

    // Orbital trajectories
    Orbit(eccentricity: 0.3, semiMajorAxis: 5.0)
}
```

## Design Principles

1. **Declarative**: Describe *what* you want, not *how* to render it
2. **Composable**: Complex scenes built from simple, reusable components
3. **Performant**: Leverage GPU parallelism and efficient batching
4. **Extensible**: Easy to add new physics concepts without changing core rendering
5. **Interactive**: Real-time parameter adjustment and animation (future)

## Technical Strengths

- **Clean Architecture**: Physics logic separated from rendering concerns
- **Metal Performance**: Direct GPU acceleration for real-time visualization
- **Type Safety**: Swift's type system prevents many common graphics bugs
- **Visitor Pattern**: Easy to add new processing stages (animation, interaction, etc.)
- **Depth Correctness**: Proper 3D rendering allows complex overlapping visualizations