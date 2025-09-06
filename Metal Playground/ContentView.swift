//
//  ContentView.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-08-31.
//

import SwiftUI
import simd

struct ContentView: View {
    let del: MetalRenderDemo?
    init() {
        do {
            del = try MetalRenderDemo()
        } catch {
            print("failed to make demo")
            del = nil
        }
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            let image = del!.getCGImage()!
            Image(image, scale: 1.0, label: Text("Hello triangle!"))
        }
        .padding()
    }
}

struct MetalRenderDemo {
    var texture: MTLTexture? = nil
    
    func makePipeline(for device: MTLDevice) -> MTLRenderPipelineDescriptor {
        let pipeline = MTLRenderPipelineDescriptor()

        // Q: why do you need a device to make a library?
        // A: the shaders need to be compiled _for this device_ to be used
        let library = device.makeDefaultLibrary()!
        
        pipeline.vertexFunction = library.makeFunction(name: "vertex_shader")!
        // TODO: fragment shader
        pipeline.fragmentFunction = library.makeFunction(name: "fragment_shader")!
        
        // this might seem redundant - we specify a pixel format for the render
        // pass descriptor too, and metal ensures that they match (throwing
        // an error if they dont). But remember
        // we might use this pipeline for many different passes! this pipeline
        // is compatible with any pass that uses rgba8Uint format for its
        // textures.
        pipeline.colorAttachments[0].pixelFormat = .rgba8Uint
        
        return pipeline
    }
    
    mutating func makeDescriptor(for device: MTLDevice, with texture: MTLTexture) -> MTLRenderPassDescriptor {
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
    
    func makeVerticesForTriangle() -> [SIMD3<Float>] {
        let triangleVertices: [SIMD3<Float>] = [
            SIMD3<Float>(-0.5, -0.5, 0.0),
            SIMD3<Float>( 0.5, -0.5, 0.0),
            SIMD3<Float>( 0.0,  0.5, 0.0)
        ]
        
        return triangleVertices
    }
    
    func getCGImage() -> CGImage? {
        let texture = self.texture!
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
    
    func makeTexture(for device: MTLDevice) -> MTLTexture {
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
    
    init() throws {
        let device = MTLCreateSystemDefaultDevice()!
        let queue = device.makeCommandQueue()!
        let buf = queue.makeCommandBuffer()!
        
        // pipeline = how to draw
        let pipelineDescriptor = makePipeline(for: device)
        let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        // pass = where to draw to
        let texture = makeTexture(for: device)
        let passDescriptor = makeDescriptor(for: device, with: texture)
        let encoder = buf.makeRenderCommandEncoder(descriptor: passDescriptor)!

        // vertices - what to draw
        let vertices = makeVerticesForTriangle()
        let vertexBuffer = device.makeBuffer(bytes: vertices,
                                             length: MemoryLayout<SIMD3<Float>>.size * vertices.count,
                                             options: [])
        
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // BOOM
        encoder.setRenderPipelineState(pipelineState)
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        encoder.endEncoding()
        buf.commit()
        buf.waitUntilCompleted()
        
        self.texture = texture
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
