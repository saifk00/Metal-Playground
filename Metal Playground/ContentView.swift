//
//  ContentView.swift
//  Metal Playground
//
//  Created by Saif Khattak on 2025-08-31.
//

import SwiftUI
import simd
import MetalKit

struct ContentView: View {
    @State private var selectedDemo: Demo = .SceneBasedPlot

    var body: some View {
        VStack {
            Text("hello metal!")
            Picker("Select a demo", selection: $selectedDemo) {
                ForEach(Demo.allCases) { demo in
                    Text(demo.rawValue)
                }
            }
            .padding()
            .frame(width: 500, height: 50)
            MetalRenderDemoView(demo: $selectedDemo)
                .frame(width: 500, height: 500)
        }
        .padding()
    }
}

enum Demo: String, CaseIterable, Identifiable {
    var id: Demo { self }

    case Triangle
    case Quad
    case Plot
    case SceneBasedPlot
}

struct Runnable {
    let pipeline: MTLRenderPipelineState?
    let runner: DemoRunner
}

#Preview {
    ContentView()
}
