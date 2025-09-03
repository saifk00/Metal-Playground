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
