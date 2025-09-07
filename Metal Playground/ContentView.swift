//
//  ContentView.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-08-31.
//

import SwiftUI
import simd

struct ContentView: View {
    @State private var speed = 180.0
    let demo: MetalRenderDemo
    init() {
        demo = try! MetalRenderDemo()
    }
    
    var body: some View {
        TimelineView(.periodic(from:.now, by: 1.0 / 360.0)) {ctx in
            VStack {
                let step = Int(speed * ctx.date.timeIntervalSinceReferenceDate)
                let image = demo.renderImage(at: step)!
                Slider(value: $speed, in: 60...360)
                Image(image, scale: 1.0, label: Text("Hello triangle!"))
            }
            .padding()
        }
    }
}

struct MyVertex {
    let time: Float
    let position: SIMD3<Float>
    
    static func vertexDescriptor() -> MTLVertexDescriptor {
        let descriptor = MTLVertexDescriptor()
        
        // notice that we directly subscript attributes rather than
        // initialize the list ourselves. this is because
        // metal defines a fixed max length of these arrays
        // and initializes them for us. so we modify them in place
        if let timeD = descriptor.attributes[0] {
            timeD.format = .float
            // the backslash is swift's "key path literal" syntax
            timeD.offset = MemoryLayout.offset(of: \MyVertex.time)!
            // notice that we have an option to interleave
            // attributes _across buffers_ (but why?)
            timeD.bufferIndex = 0
        }
        
        if let posD = descriptor.attributes[1] {
            posD.format = .float3
            posD.offset = MemoryLayout.offset(of: \MyVertex.position)!
            posD.bufferIndex = 0
        }
        
        if let buf0Layout = descriptor.layouts[0] {
            buf0Layout.stepFunction = .perVertex
            buf0Layout.stride = MemoryLayout<MyVertex>.stride
            // meaningless since stepFunction is pervertex,
            // but set it anyway for explicitness
            buf0Layout.stepRate = 1
        }
        
        return descriptor
    }
}

struct MetalRenderDemo {
    static func makePipelineDescriptor(for device: MTLDevice) -> MTLRenderPipelineDescriptor {
        let pipeline = MTLRenderPipelineDescriptor()

        // Q: why do you need a device to make a library?
        // A: the shaders need to be compiled _for this device_ to be used
        let library = device.makeDefaultLibrary()!
        
        pipeline.vertexFunction = library.makeFunction(name: "vertex_shader")!
        pipeline.fragmentFunction = library.makeFunction(name: "fragment_shader")!
        
        // this might seem redundant - we specify a pixel format for the render
        // pass descriptor too, and metal ensures that they match (throwing
        // an error if they dont). But remember
        // we might use this pipeline for many different passes! this pipeline
        // is compatible with any pass that uses rgba8Uint format for its
        // textures.
        pipeline.colorAttachments[0].pixelFormat = .rgba8Uint
        
        pipeline.vertexDescriptor = MyVertex.vertexDescriptor()
        
        return pipeline
    }
    
    static func makePassDescriptor(for device: MTLDevice, with texture: MTLTexture) -> MTLRenderPassDescriptor {
        let descriptor = MTLRenderPassDescriptor()
 
        // ... we now tell metal that this descriptor has a color attachment
        //     at this location on the device.
        descriptor.colorAttachments[0].texture = texture
        // when you start rendering, load the texture, clear it with red. when done,
        // store the data back to that same texture
        descriptor.colorAttachments[0].loadAction = .clear
        // the values here are interpreted with respect to the pixelformat of the corresponding texture
        // since we are using rgbaUint8, we need to provide values in range [0, 255]
        descriptor.colorAttachments[0].clearColor = .init(red: 255.0, green: 0.0, blue: 0.0, alpha: 128.0)
        descriptor.colorAttachments[0].storeAction = .store
        
        return descriptor
    }
    
    static func makeVerticesForTriangle(at time: Int) -> [MyVertex] {
        let t = Float(time)
        let triangleVertices: [MyVertex] = [
            MyVertex(time: t, position: SIMD3<Float>(-0.5, -0.5, 0.0)),
            MyVertex(time: t, position: SIMD3<Float>( 0.5, -0.5, 0.0)),
            MyVertex(time: t, position: SIMD3<Float>( 0.0,  0.5, 0.0))
        ]
        
        return triangleVertices
    }
    
    func render(at time: Int) {
        // 1. do the drawing
        let wrappedTime = time % tResolution
        if let buf = queue.makeCommandBuffer() {
            let encoder = buf.makeRenderCommandEncoder(
                descriptor: MetalRenderDemo.makePassDescriptor(for: device, with: texture))!
            
            
            encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            encoder.setRenderPipelineState(pipeline)
            
            // we copied the vertex data maxT times, so we can just render the triangles
            // at time*3 to get the right time values
            encoder.drawPrimitives(type: .triangle, vertexStart: wrappedTime * 3, vertexCount: 3)
            
            encoder.endEncoding()
            
            buf.commit()
            buf.waitUntilCompleted()
        }
    }
    
    func renderImage(at time: Int) -> CGImage? {
        self.render(at: time)
        return getCGImage()
    }
    
    private func getCGImage() -> CGImage? {
        let width = texture.width
        let height = texture.height
        let rowBytes = width * 4

        var pixels = [UInt8](repeating: 0, count: rowBytes * height)

        let region = MTLRegionMake2D(0, 0, width, height)
        texture.getBytes(&pixels,
                         bytesPerRow: rowBytes,
                         from: region,
                         mipmapLevel: 0)

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let ctx = CGContext(data: &pixels,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: 8,
                                  bytesPerRow: rowBytes,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }

        return ctx.makeImage()
    }
    
    static func makeTexture(for device: MTLDevice) -> MTLTexture {
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba8Uint,
            width: 256,
            height: 256,
            mipmapped: false)
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        
        // so the actual texture data is now stored on the device, with
        // undefined values. `texture` is a host reference to this memory,
        // which can be used in other API calls, for example...
        return device.makeTexture(descriptor: textureDescriptor)!
    }
    
    let device: MTLDevice
    let queue: MTLCommandQueue
    let pipeline: MTLRenderPipelineState
    let texture: MTLTexture
    let vertexBuffer: MTLBuffer
    let tResolution: Int = 360
    
    init() throws {
        device = MTLCreateSystemDefaultDevice()!
        queue = device.makeCommandQueue()!
        // pipeline = how to draw
        pipeline = try device.makeRenderPipelineState(
            descriptor: MetalRenderDemo.makePipelineDescriptor(for: device))
        
        // pass = where to draw to
        texture = MetalRenderDemo.makeTexture(for: device)
        
        // vertices - what to draw
        let times = Array(0...tResolution)
        let vertices: [MyVertex] = times.flatMap { t in
            MetalRenderDemo.makeVerticesForTriangle(at: t)
        }
        
        // keep it around because every time we make an encoder we will have to
        // say that we're using this vertex buffer
        vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: MemoryLayout<MyVertex>.size * vertices.count,
                                             options: [])!
    }
}

struct MetalComputeDemo {
    let result: [Int64]
    init() {
        let device = MTLCreateSystemDefaultDevice()!
        let queue = device.makeCommandQueue()!
        let buf = queue.makeCommandBuffer()!
        let encoder = buf.makeComputeCommandEncoder()!
        
        let A = [1, 2, 3, 4, 5, 6, 0, 0, 0]
        
        let bufLength = A.count * MemoryLayout<Int64>.stride
        let subLength = 3 * MemoryLayout<Int64>.stride
        
        let arrayBuf = device.makeBuffer(bytes: A, length: bufLength)

        encoder.setBuffer(arrayBuf, offset: 0, index: 0)
        encoder.setBuffer(arrayBuf, offset: subLength, index: 1)
        encoder.setBuffer(arrayBuf, offset: 2*subLength, index: 2)
        
        let library = device.makeDefaultLibrary()!
        let addArraysFunc = library.makeFunction(name: "add_arrays")!

        var pipeline: MTLComputePipelineState
        do {
            pipeline = try device.makeComputePipelineState(function: addArraysFunc)
        } catch {
            print("pipeline creation failed")
            self.result = []
            return
        }
        
        encoder.setComputePipelineState(pipeline)
        
        let gridShape = MTLSize(width: 1, height: 1, depth: 1)
        let groupShape = MTLSize(width: A.count, height: 1, depth: 1)
        encoder.dispatchThreadgroups(gridShape, threadsPerThreadgroup: groupShape)
        
        encoder.endEncoding()
        buf.commit()
        buf.waitUntilCompleted()
        
        let outPtr = arrayBuf?.contents().bindMemory(to: Int64.self, capacity: A.count)
        let startPtr = outPtr! + 6
        let bufPtr = UnsafeBufferPointer(start: startPtr, count: 3)
        self.result = Array(bufPtr)
    }
}

#Preview {
    ContentView()
}
