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

vertex float4 vertex_shader(uint vertexID [[vertex_id]],
                           constant simd::float3* vertexPositions) {
    float4 vertexOutPositions = float4(vertexPositions[vertexID][0],
                                       vertexPositions[vertexID][1],
                                       vertexPositions[vertexID][2],
                                       1.0f);
    return vertexOutPositions;
}
 

fragment uint4 fragment_shader() {
    return uint4(0, 255, 0, 255);
}
