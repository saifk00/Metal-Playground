//
//  basic.metal
//  Metal Playground
//
//  Created by Saif Khattak on 2025-08-31.
//

#include <metal_stdlib>
using namespace metal;


kernel void add_arrays(device long* A [[buffer(0)]],
                       device long* B [[buffer(1)]],
                       device long* C [[buffer(2)]],
                       uint gid [[thread_position_in_grid]]) {
    if (gid > 2) return;
    
    C[gid] = B[gid] + A[gid];
}

struct VertexInput {
    float3 position [[ attribute(1) ]];
    float time [[ attribute(0) ]];
};

struct VertexOutput {
    float4 pos [[ position ]];
};


float line_segment(float2 pt, float2 start, float2 end, float thickness) {
    // TODO - a diagonal step function subtract an offset diagonal step function
    // and then a step if the x and y's are within range
    
    // points perp to the line (rotate the start->end vec by pi/2)
    float2 norm = normalize(float2x2(0, -1, 1, 0) * (end - start));
    float dir = dot((pt - start), norm);
    float plane1 = step(0.0, dir); // 1 when above the line, 0 otherwise
    
    // now add a little nudge in the norm direction for the other startpoint
    float2 start2 = start + thickness * norm;
    float dir2 = dot((pt - start2), norm);
    float plane2 = step(0.0, dir2); // 1 when above the second line, 0 otherwise
    
    
    float maxX = max(start.x, end.x);
    float maxY = max(start.y, end.y);
    float minX = min(start.x, end.x);
    float minY = min(start.y, end.y);
    
    // 1 if you are to the BL of the max point
    float f1 = 1 - smoothstep(maxY, maxY + thickness, pt.y)*smoothstep(maxX, maxX + thickness, pt.x);
    // 1 if you are to the TR of the min point
    float f2 = smoothstep(minY, minY+thickness, pt.y) * smoothstep(minX, minX + thickness, pt.x);
    // 1 if you are to the BL of the max point AND TR of the min point, thus
    // within bounds.
    float f = f1 * f2;
    
    return f * (plane1 - plane2);
}

fragment float4 quad_fragment_shader(float4 in [[ position ]]) {
    float2 st = in.xy / float2(1000.); // retina -> 500x500 is actually a 1000x1000!
    st.y = 1.0 - st.y;
    
    float line = line_segment(st,
                            float2(0.25, 0.25),
                            float2(0.75, 0.75),
                            0.01);
    float line2 = line_segment(st,
                               float2(0.1, 0.8),
                               float2(0.7, 0.2),
                               0.02);
    float3 color = float3(st.x, 0.0, st.y);
    color = color * (line + line2);
    
    // TODO why is it slightly transluscent...
    return float4(color, 1.0);
}
 
vertex float4 quad_vertex_shader(VertexInput vIn [[ stage_in ]]) {
    return float4(vIn.position, 1.0);
}

vertex float4 vertex_shader(VertexInput vIn [[ stage_in ]]) {
    float phase = M_PI_F * (vIn.time / 180.0f);
    // breathe from 0.2 to 1.0
    float wMin = 0.5;
    float wMax = 8;
    float wMid = (wMin + wMax) / 2.0;
    float wScale = wMid + (wMax - wMid)*sin(phase);
    
    float4 vOut = float4(vIn.position[0],
                         vIn.position[1],
                         vIn.position[2],
                         wScale);
    return vOut;
}

// TODO get the screen point into the frag shader and pass it to line segment to test
fragment half4 fragment_shader(float4 in [[ position ]]) {
    float2 st = in.xy / float2(500., 500.);
    return half4(st.x, st.y, 0.0, 1.0);
}
