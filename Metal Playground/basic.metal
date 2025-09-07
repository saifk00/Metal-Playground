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

vertex float4 vertex_shader(VertexInput vIn [[ stage_in ]]) {
    float phase = 2 * M_PI_F * (vIn.time / 100.0f);
    float u = 0.5f * (1 + sin(phase)); // in [0, 1]
    
    // breathe from 0.2 to 10
    float wMin = 0.2;
    float wMax = 1.0;
    float wScale = wMin + u * (wMax - wMin);
    
    float4 vOut = float4(vIn.position[0],
                                       vIn.position[1],
                                       vIn.position[2],
                                       wScale);
    return vOut;
}
 

fragment uint4 fragment_shader() {
    return uint4(0, 255, 0, 255);
}
