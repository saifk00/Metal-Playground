# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS Metal graphics playground application built with SwiftUI. The app demonstrates various Metal rendering techniques through an interactive demo selection interface. The project is structured around a clean architecture using protocol-based demo runners.

## Architecture

### Core Components

- **DemoRunner Protocol**: Defines the interface for all rendering demos with three key methods:
  - `initPipeline(for:)`: Creates Metal render pipeline state
  - `initBuffers(for:)`: Initializes vertex/index buffers
  - `draw(with:)`: Executes rendering commands

- **MetalRenderDemo**: Main rendering coordinator that manages:
  - Device/command queue initialization
  - Demo caching via `demoCache: [Demo : Runnable]`
  - Frame rendering loop with MTKViewDelegate

- **Demo Implementations**:
  - `TriangleDemo`: Animated triangle with time-based scaling
  - `QuadDemo`: Static quad with procedural line segment rendering

### Key Files

- `DemoRunner.swift`: Core protocol definition
- `MetalRenderDemo.swift`: Main rendering engine and demo cache management
- `ContentView.swift`: SwiftUI interface with demo picker
- `MyVertex.swift`: Vertex structure with Metal vertex descriptor
- `basic.metal`: Metal shaders including vertex/fragment shaders and compute kernels
- `TriangleDemo.swift`/`QuadDemo.swift`: Individual demo implementations

## Development Commands

This is an Xcode project for macOS. Use standard Xcode build commands:

- **Build**: Cmd+B in Xcode or `xcodebuild -project "Metal Playground.xcodeproj" -scheme "Metal Playground" build`
- **Run**: Cmd+R in Xcode
- **Test**: Cmd+U in Xcode or `xcodebuild test -project "Metal Playground.xcodeproj" -scheme "Metal Playground"`

The project targets macOS 15.5+ and uses Swift 5.0.

## Adding New Demos

1. Create a new struct conforming to `DemoRunner`
2. Add the demo case to the `Demo` enum in `ContentView.swift`
3. Initialize and cache the demo in `MetalRenderDemo.init()`
4. Implement required Metal shaders in `basic.metal`

The demo cache pattern ensures efficient pipeline state reuse across render frames.
