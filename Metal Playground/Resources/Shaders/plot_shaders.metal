//
//  plot_shaders.metal
//  Metal Playground
//
//  Created by Claude on 2025-09-13.
//

#include <metal_stdlib>
using namespace metal;

// Vertex input structure matching PlotDSLVertex
struct PlotVertexIn {
    float3 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

// Vertex output structure
struct PlotVertexOut {
    float4 position [[position]];
    float4 color;
};

// Create view matrix: camera looking at origin
float4x4 createViewMatrix() {
    float camHeight = 1; // distance from XY plane
    float camDistance = 3.2; // distance from Z axis
    float camTheta = -M_PI_F/3 + 0.3; // rotation about Z axis (adjusted for more natural view)
    // Compute eye position using cylindrical coordinates
    float3 eye = float3(
        camDistance * cos(camTheta),  // X coordinate
        camDistance * sin(camTheta),  // Y coordinate  
        camHeight                     // Z coordinate (height above XY plane)
    );
    float3 center = float3(0.0, 0.0, 0.0);
    float3 up = float3(0.0, 0.0, 1.0);  // Z is up
    
    float3 f = normalize(center - eye);  // forward
    float3 s = normalize(cross(f, up));  // right
    float3 u = cross(s, f);              // up
    
    float4x4 view = float4x4(
        float4(s.x, u.x, -f.x, 0.0),
        float4(s.y, u.y, -f.y, 0.0),
        float4(s.z, u.z, -f.z, 0.0),
        float4(-dot(s, eye), -dot(u, eye), dot(f, eye), 1.0)
    );
    
    return view;
}

// Create perspective projection matrix
float4x4 createProjectionMatrix() {
    float fovy = 45.0 * M_PI_F / 180.0;  // 45 degrees in radians
    float aspect = 1.0;  // Square viewport
    float near = 0.1;
    float far = 10.0;
    
    float f = 1.0 / tan(fovy * 0.5);
    
    float4x4 proj = float4x4(
        float4(f / aspect, 0.0, 0.0, 0.0),
        float4(0.0, f, 0.0, 0.0),
        float4(0.0, 0.0, (far + near) / (near - far), -1.0),
        float4(0.0, 0.0, (2.0 * far * near) / (near - far), 0.0)
    );
    
    return proj;
}

// Vertex shader for plot rendering
vertex PlotVertexOut plot_vertex_shader(PlotVertexIn in [[stage_in]]) {
    PlotVertexOut out;
    
    // Transform vertex position with view and projection matrices
    float4 worldPos = float4(in.position, 1.0);
    float4 viewPos = createViewMatrix() * worldPos;
    out.position = createProjectionMatrix() * viewPos;
    
    // Use the vertex color
    out.color = in.color;
    
    return out;
}

// Fragment shader for plot rendering
fragment float4 plot_fragment_shader(PlotVertexOut in [[stage_in]]) {
    // Simple pass-through - use the interpolated color
    return in.color;
}
