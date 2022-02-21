//
//  Unlit.metal
//  InverseKinematics
//
//  Created by Danny Jang on 2022/02/20.
//

#include <metal_stdlib>
#include "Bridge.h"
using namespace metal;

struct Input {
    float4 position [[attribute(0)]];
};

struct Output {
    float4 pos [[position]];
};

vertex Output vertex_main(const Input input [[stage_in]],
                          constant CameraBuffer& camera_buffer [[buffer(1)]],
                          constant MeshBuffer& mesh_buffer [[buffer(2)]]) {
    float4x4 mvp = camera_buffer.projection * camera_buffer.view * mesh_buffer.model;
    Output output;
    output.pos = mvp * input.position;
    return output;
}

fragment float4 fragment_main(constant MeshBuffer& mesh_buffer [[buffer(2)]]) {
    return float4(mesh_buffer.color, 1.0);
}
